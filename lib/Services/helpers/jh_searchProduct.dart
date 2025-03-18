import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:fiberchat/Utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

final url = Uri.parse('https://serpapi.com/search');
final apiKey =
    'eebb9a65609351170f67ad9e08e764d86f6ee70639cdd458561eab82d4dbedd4';

Future<Map<String, Map<String, String>>> searchProduct(
    String imageUrl, BuildContext context) async {
  print("sP: searchProduct running");

  String searchUrl = "https://picxer.org/piclink.php?url=$imageUrl";
  //IMPORTANT: if I access the firebase doc directly, that's not possible according to serpapi-support. Therefore, this workaround is needed
  searchUrl = searchUrl.replaceAll("&token",
      "token"); // needed because otherwise the "&" symbol will be cut away by serpapi. this will be added back by my php-script on my server
  searchUrl = searchUrl.replaceAll("%2F",
      "baeckslaesh"); // needed because otherwise the "&" symbol will be cut away by serpapi. this will be added back by my php-script on my server
  searchUrl = searchUrl.replaceAll("PICXER/",
      "PICXERbaeckslaesh"); // needed because otherwise the "&" symbol will be cut away by serpapi. this will be added back by my php-script on my server
  final response;
  try {
    // ignore: body_might_complete_normally_catch_error

    response = await http.get(
      url.replace(queryParameters: {
        'api_key': apiKey,
        'engine': "google_lens",
        'url': searchUrl,
      }),
    );

    print("sP: Response status code: " +
        response.statusCode.toString() +
        " imageUrl: " +
        imageUrl +
        " searchUrl: " +
        searchUrl +
        " response.body: " +
        response.body.toString());

    if (response.statusCode == 200) {
      //FOR TESTING: Save response body to a file
      final tempDir = await getTemporaryDirectory();
      final filePath = join(tempDir.path, 'response_body.txt');
      final file = File(filePath);
      await file.writeAsString(response.body);
      print('sP: Response body saved to file: ${file.path}');

      final mapResponse = json.decode(response.body);
      Map<String, Map<String, String>> productData = {};
      if (mapResponse.length > 0) {
        print("sP: mapResponse is not 0");
        productData = await analyseResponse(mapResponse, context);
      }

      return productData;
    } else {
      // Error handling
      print('sP: Request failed with status: ${response.statusCode}');

      return {};
    }
  } catch (err) {
    Fiberchat.toast('No internet connection.');
    return {};
  }
}

searchProductInShopping(itemTitle) async {
  String keyword = itemTitle + " amazon";
  final response = await http.get(
    url.replace(queryParameters: {
      'api_key': apiKey,
      'engine': "google_shopping",
      'q': keyword,
    }),
  );

  if (response.statusCode == 200) {
    //FOR TESTING: Save response body to a file
    final tempDir = await getTemporaryDirectory();
    final filePath = join(tempDir.path, 'response_body_shopping.txt');
    final file = File(filePath);
    await file.writeAsString(response.body);
    print('sPP: Response body saved to file: ${file.path}');

    final mapResponse = json.decode(response.body);
    if (mapResponse.length > 0) {
      print("sPP: mapResponse is not 0");
    }
    return mapResponse;
  } else {
    // Error handling
    print('sPP: Request failed with status: ${response.statusCode}');
    return {};
  }
}

Future<Map<String, Map<String, String>>> analyseResponse(
    Map<String, dynamic> data, BuildContext context) async {
  // Parse the JSON response into a Map
  Map<String, String> links = {};
  Map<String, String> thumbnails = {};
  int currentNumberOfResults = 0;
  print("sP: currentNumberOfResults: " + currentNumberOfResults.toString());
  print("sP: Adding a kno Break");
  int maxNumberOfResults = 5;

//Best option: Search for product on google products and check if there*s an amazon product for it

  try {
    if (currentNumberOfResults < maxNumberOfResults) {
      //1.5th Best option: Extract titles of Links which point to amazon (because these are definetly products)
      try {
        for (var item in data['visual_matches']) {
          if (currentNumberOfResults < (maxNumberOfResults - 3)) {
            print("sP: Adding a visual match. currentNumberOfResults: " +
                currentNumberOfResults.toString());
            if (item['link'].contains("amazon")) {
              String uri = amazonAffiliateLink(item['title'],
                  context); //suche auf titel lassen weil wenn ich die original-links nehme kommt man oft auf produkt das entweder nciht mehr verfügbar ist oder in ganz anderem land
              links[item['title'].toString()] = uri;
              thumbnails[item['title'].toString()] = item['thumbnail'];
              currentNumberOfResults++;
            }
          }
        }
      } catch (e) {
        print(
            'sP: Couldnt extract data from response (visual matches) in analyseResponse-Function');
      }
    }
  } catch (e) {
    print(
        'sP: Couldnt extract data from response (visual matches) in analyseResponse-Function');
  }
  print(
      "links after 1:" + currentNumberOfResults.toString() + links.toString());

  int iterationCount = 1;

  for (var item in data['visual_matches']) {
    if (iterationCount > 2) {
      print("chck break");
      break; // Exit the loop if the maximum number of iterations is reached.
    }
    if (currentNumberOfResults < maxNumberOfResults) {
      print("chck if1");
      print(
          "sP: Adding a amazon product shopping match. currentNumberOfResults: " +
              currentNumberOfResults.toString());
      String link = "";
      var responseProduct = await searchProductInShopping(item['title']);

      for (var product in responseProduct['shopping_results']) {
        print("chck blaaaa" + responseProduct.toString());

        link = product['link'];
        print("chck for1");
        print('Link: $link');
        print("Link: currentNumberOfResults:" +
            currentNumberOfResults.toString() +
            "maxNumberOfResults" +
            maxNumberOfResults.toString());
        if ((link.contains('amazon')) &
            (currentNumberOfResults < maxNumberOfResults)) {
          print('Link: $link');
          print("chck if4");
          print("chck if4 product title:" + product['title']);
          print("chck if4 product thumbnaiil:" + product['thumbnail']);

          String uri = amazonAffiliateLink(product['title'],
              context); //suche auf titel lassen weil wenn ich die original-links nehme kommt man oft auf produkt das entweder nciht mehr verfügbar ist oder in ganz anderem land
          links[product['title'].toString()] = uri;

          print("chck if4 links:" + links.toString());
          thumbnails[product['title'].toString()] = product['thumbnail'];
          currentNumberOfResults++;
        }
      }
    }
    iterationCount++;
  }
  print("links after 1.5:" +
      currentNumberOfResults.toString() +
      links.toString());

  //Second best option: Extract titles of Links  which point to something that relates to a product
  if (currentNumberOfResults < maxNumberOfResults) {
    try {
      for (var item in data['visual_matches']) {
        if (currentNumberOfResults < maxNumberOfResults) {
          print(
              "sP: Adding a link that somehow relates to a product. currentNumberOfResults: " +
                  currentNumberOfResults.toString());
          if ((item['link'].contains("ebay") ||
                  item['link'].contains("product") ||
                  item['link'].contains("shop") ||
                  item['link'].contains("buy")) &
              (!item['link'].contains("amazon"))) {
            if (item['link'].contains("product")) {
              print("sP: found product");
            }
            if (item['link'].contains("shop")) {
              print("sP: found shop");
            }
            if (item['link'].contains("buy")) {
              print("sP: found buy");
            }
            if (item['link'].contains("ebay")) {
              print("sP: found ebay");
            }

            String uri = "https://www.google.com/search?q=" +
                item['title'] +
                "&tbm=shop"; //suche auf titel lassen weil wenn ich die original-links nehme kommt man oft auf produkt das entweder nciht mehr verfügbar ist oder in ganz anderem land
            links[item['title'].toString()] = uri;
            thumbnails[item['title'].toString()] = item['thumbnail'];
            currentNumberOfResults++;
          }
        }
      }
    } catch (e) {
      print(
          'sP: Couldnt extract data from response (visual matches) in analyseResponse-Function');
    }
  }
  print(
      "links after 2:" + currentNumberOfResults.toString() + links.toString());

//Third best option: Titles knowledge graph
  if (currentNumberOfResults < maxNumberOfResults) {
    try {
      for (var item in data['knowledge_graph']) {
        if (currentNumberOfResults < maxNumberOfResults) {
          print("itemtitle:" + item['title'].toString());
          String uri = item[
              'link']; //hier einfach auf das bild verlinken weil ist scheinbar gar kein produkt
          links[item['title'].toString()] = uri;
          if (thumbnails.containsKey(item['thumbnail'])) {
            thumbnails[item['title'].toString()] = item['thumbnail'];
          } else {
            thumbnails[item['title'].toString()] =
                data['visual_matches'][currentNumberOfResults + 1]['thumbnail'];
          } //if no thumbnail exists, use thumbnail of visuals because there are sometimes no thumbnails for knowledge_graph
          print("sP: Adding a knowledge_graph: " +
              item['title'].toString() +
              item['thumbnail']);
          currentNumberOfResults++;
        }
      }
    } catch (e) {
      print(
          'sP: Couldnt extract data from response (knowledge_graph) in analyse Response-Function');
    }
  }

  print(
      "links after 3:" + currentNumberOfResults.toString() + links.toString());

  //4th best option: Take any visual match
  if (currentNumberOfResults < maxNumberOfResults) {
    try {
      for (var item in data['visual_matches']) {
        if (currentNumberOfResults < maxNumberOfResults) {
          print("sP: Adding a visual match. currentNumberOfResults: " +
              currentNumberOfResults.toString());
          if (!(item['link'].contains("amazon") ||
              item['link'].contains("ebay") ||
              item['link'].contains("product") ||
              item['link'].contains("shop") ||
              item['link'].contains("buy"))) {
            String uri = item[
                'link']; //hier einfach auf das bild verlinken weil ist scheinbar gar kein produkt
            links[item['title'].toString()] = uri;
            thumbnails[item['title'].toString()] = item['thumbnail'];
            currentNumberOfResults++;
          }
        }
      }
    } catch (e) {
      print(
          'sP: Couldnt extract data from response (visual matches) in analyseResponse-Function');
    }
  }
  print(
      "sP: found amazon titles + product titles + knowledge graph + any visual match: " +
          currentNumberOfResults.toString());

  print(
      "links after 4:" + currentNumberOfResults.toString() + links.toString());

  Map<String, Map<String, String>> productData = {
    "links": links,
    "thumbnails": thumbnails,
  };
  return productData;
}

String amazonAffiliateLink(String searchTerm, BuildContext context) {
  String formattedSearchTerm =
      searchTerm.replaceAll(' ', '+'); //needed because otherwise blanks in  url
  String uri = "";
  String countryEnding = getCountryEnding(context);
  uri = "https://www.amazon" + countryEnding + "/s?k=" + formattedSearchTerm;
  return uri;
}

String getCountryEnding(BuildContext context) {
  Locale locale = window.locale;
  return _mapLocaleToAmazonMarketPlaceEnding(locale);
}

String _mapLocaleToAmazonMarketPlaceEnding(Locale locale) {
  // Map of country codes to ccTLDs
  Map<String, String> ccTLDs = {
    'DE': '.de',
    'US': '.com',
    'CA': '.ca',
    'MX': '.com.mx',
    'BR': '.com.br',
    'UK': '.co.uk',
    'FR': '.fr',
    'IT': '.it',
    'ES': '.es',
    'PL': '.pl',
    'NL': '.nl',
    'SE': '.se',
    'AE': '.ae',
    'SA': '.sa',
    'AU': '.com.au',
    'JP': '.co.jp',
    'SG': '.sg',
    'TR': '.com.tr',
    'IN': '.in',
    'CN': '.cn'
  };
  return ccTLDs[locale.countryCode] ?? '.com'; // Default to .com if not found
}
/* Das hier wäre mit Amazon Product search API aber dafür müsste ich:
Zum Anfragen eines PA API-Zugangs musst Du:

❌ 3 qualifizierte Verkäufe in 180 Tagen abgewickelt haben.
❌ ein genehmigtes Partnerkonto haben.
❌ den Teilnahmebedingungen des Partnerprogramms entsprechen.

Future<int> checkIfAmazonHasGoodResults(String titleOfPotentialProduct) async {
  int score = 0;

  final String baseUrl = 'https://merchant-api.amazon.com/product-search/v1';
  String apiKey = ""; XXXXXX;
  String keyword = ""; XXXXXX;
  final Uri uri = Uri.parse('$baseUrl/items');
  final Map<String, String> headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  final Map<String, dynamic> queryParameters = {
    'keywords': keyword,
    'marketplaceIds':
        'ATVPDKIKX0DER', // Replace with your desired marketplace ID(s)
    'itemCount':
        '10', // Replace with the desired number of items in the response
    // Add other optional query parameters as needed
  };

  final http.Response response = await http
      .get(uri.replace(queryParameters: queryParameters), headers: headers);

  if (response.statusCode == 200) {
    // Request successful
    final String responseBody = response.body;
    // Process the response data
    print(responseBody);
  } else {
    // Request failed
    print('Request failed with status: ${response.statusCode}');
  }

  return score;
} */

/*VERALTET (wäre ansatz mit die seite scrapen):
List<dynamic> extractData(dynamic soup) {
  var scriptElements = soup.querySelectorAll('script');
  var rawDatas = scriptElements
      .where((element) => element.text.contains('Visual matches'))
      .toList();

  var rawData = rawDatas[0].text;
  var start = rawData.indexOf('data:') + 5;
  var end = rawData.indexOf('sideChannel') - 2;
  var jsonData = json.decode(rawData.substring(start, end));

  var jason = [];
  try {
    jason =
        jsonData[1][1][1][8][8][0][12] ?? jsonData[1][0][1][8][8][0][12] ?? [];
  } catch (e) {
    print('sP: The data is not in the expected format');
  }

  List<Map<String, dynamic>> productData = [];
  for (var product in jason) {
    var information = {
      'google_image': product[0][0],
      'title': product[3],
      'redirect_url': product[5],
      'redirect_name': product[14],
      // 'price': product[0][7][1] if len(product[0]) > 6 else null
    };
    productData.add(information);
  }
  print("sP: productData: " +
      productData.length.toString() +
      productData.toString());
  inspect(productData);
  return productData;
}

//Make a GET request to https://lens.google.com/uploadbyurl?url=YOUR_IMAGE_URL




//You will also need to play around with your headers. I think User-Agent is necessary along others.





import 'jh_searchProduct'json, bs4, request
def extract_data(soup):
    //This function is used to extract the data of a google lens page (response of bd_proxy_search  )

    Args:
        soup (bs4.BeautifulSoup): the html of the page (response of bd_proxy_search  )
    Returns:
        product_list (list): a list of dictionaries containing the data"""
    # Finds an element containig 'Visual Matches'  and returns a json object containing the data
    script_elements = soup.find_all('script')

    raw_data = [x for x in script_elements if 'Visual matches' in x.text]

    raw_data = raw_data[0].text

    start = raw_data.find('data:')+5
    end = raw_data.find('sideChannel') -2
    json_data = json.loads(raw_data[start:end])

    jason = []

    ###########################################
    # This is used beacuse sometimes the information is in json_data[1][0] and other times in json_data[1][1]
    try:
        jason = json_data[1][1][1][8][8][0][12] if len(json_data[1]) == 2 else json_data[1][0][1][8][8][0][12]
    except:
        print("The data is not in the expected format")
    ###########################################

    product_list = []
    for product in jason:
        information = {
            'google_image': product[0][0],
            'title': product[3],
            'redirect_url': product[5],
            'redirect_name': product[14],
            # 'price': product[0][7][1] if len(product[0]) > 6 else None

        }
        product_list.append(information)

    return product_list

    */
