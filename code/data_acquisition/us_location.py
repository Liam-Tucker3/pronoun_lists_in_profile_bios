##### Begin code for function to filter to US location strings. #####
def us_location(location):
	new_england = r'New England'
	
	states_pattern = r'\bAlabama\b|\bAlaska\b|\bArizona\b|\bArkansas\b|\bCalifornia\b|\bColorado\b|\bConnecticut\b|\bDelaware\b|\bFlorida\b|\bGeorgia\b|\bHawaii\b|\bIdaho\b|\bIllinois\b|\bIndiana\b|\bIowa\b|\bKansas\b|\bKentucky\b|\bLouisiana\b|\bMaine\b|\bMaryland\b|\bMassachusetts\b|\bMichigan\b|\bMinnesota\b|\bMississippi\b|\bMissouri\b|\bMontana\b|\bNebraska\b|\bNevada\b|\bNew Hampshire\b|\bNew Jersey\b|\bNew Mexico\b|\bNew York\b|\bNorth Carolina\b|\bNorth Dakota\b|\bOhio\b|\bOklahoma\b|\bOregon\b|\bPennsylvania\b|\bRhode Island\b|\bSouth Carolina\b|\bSouth Dakota\b|\bTennessee\b|\bTexas\b|\bUtah\b|\bVermont\b|\bVirginia\b|\bWashington\b|\bWest Virginia\b|\bWisconsin\b|\bWyoming\b'
	
	countries_pattern = r'\bAfghanistan\b|\bAlbania\b|\bAlgeria\b|\bAndorra\b|\bAngola\b|\bAntigua\b|\bBarbuda\b|\bArgentina\b|\bArmenia\b|\bAustralia\b|\bAustria\b|\bAzerbaijan\b|\bBahamas\b|\bBahrain\b|\bBangladesh\b|\bBarbados\b|\bBelarus\b|\bBelgium\b|\bBelize\b|\bBenin\b|\bBhutan\b|\bBolivia\b|\bBosnia\b|\bHerzegovina\b|\bBotswana\b|\bBrazil\b|\bBrunei\b|\bBulgaria\b|\bBurkina Faso\b|\bBurundi\b|\bCabo Verde\b|\bCambodia\b|\bCameroon\b|\bCanada\b|\bCentral African Republic\b|\bChad\b|\bChile\b|\bChina\b|\bColombia\b|\bComoros\b|\bDemocratic Republic of the Congo\b|\bRepublic of the Congo\b|\bCongo\b|\bCosta Rica\b|\bCote d\'Ivoire\b|\bCroatia\b|\bCuba\b|\bCyprus\b|\bCzechia\b|\bDenmark\b|\bDjibouti\b|\bDominica\b|\bDominican Republic\b|\bEcuador\b|\bEgypt\b|\bEl Salvador\b|\bEquatorial Guinea\b|\bEritrea\b|\bEstonia\b|\bEswatini\b|\bSwaziland\b|\bEthiopia\b|\bFiji\b|\bFinland\b|\bFrance\b|\bGabon\b|\bGambia\b|\bGermany\b|\bGhana\b|\bGreece\b|\bGrenada\b|\bGuatemala\b|\bGuinea\b|\bGuinea-Bissau\b|\bGuyana\b|\bHaiti\b|\bHonduras\b|\bHungary\b|\bIceland\b|\bIndia\b|\bIndonesia\b|\bIran\b|\bIraq\b|\bIreland\b|\bIsrael\b|\bItaly\b|\bJamaica\b|\bJapan\b|\bJordan\b|\bKazakhstan\b|\bKenya\b|\bKiribati\b|\bKosovo\b|\bKuwait\b|\bKyrgyzstan\b|\bLaos\b|\bLatvia\b|\bLebanon\b|\bLesotho\b|\bLiberia\b|\bLibya\b|\bLiechtenstein\b|\bLithuania\b|\bLuxembourg\b|\bMadagascar\b|\bMalawi\b|\bMalaysia\b|\bMaldives\b|\bMali\b|\bMalta\b|\bMarshall Islands\b|\bMauritania\b|\bMauritius\b|\bMexico\b|\bMicronesia\b|\bMoldova\b|\bMonaco\b|\bMongolia\b|\bMontenegro\b|\bMorocco\b|\bMozambique\b|\bMyanmar\b|\bBurma\b|\bNamibia\b|\bNauru\b|\bNepal\b|\bNetherlands\b|\bNew Zealand\b|\bNicaragua\b|\bNiger\b|\bNigeria\b|\bNorth Korea\b|\bNorth Macedonia\b|\bMacedonia\b|\bNorway\b|\bOman\b|\bPakistan\b|\bPalau\b|\bPalestine\b|\bPanama\b|\bPapua New Guinea\b|\bParaguay\b|\bPeru\b|\bPhilippines\b|\bPoland\b|\bPortugal\b|\bQatar\b|\bRomania\b|\bRussia\b|\bRwanda\b|\bSaint Kitts\b|\bNevis\b|\bSaint Lucia\b|\bSaint Vincent and the Grenadines\b|\bSamoa\b|\bSan Marino\b|\bSao Tome\b|\bPrincipe\b|\bSaudi Arabia\b|\bSenegal\b|\bSerbia\b|\bSeychelles\b|\bSierra Leone\b|\bSingapore\b|\bSlovakia\b|\bSlovenia\b|\bSolomon Islands\b|\bSomalia\b|\bSouth Africa\b|\bSouth Korea\b|\bSouth Sudan\b|\bSpain\b|\bSri Lanka\b|\bSudan\b|\bSuriname\b|\bSweden\b|\bSwitzerland\b|\bSyria\b|\bTaiwan\b|\bTajikistan\b|\bTanzania\b|\bThailand\b|\bTimor-Leste\b|\bTogo\b|\bTonga\b|\bTrinidad\b|\bTobago\b|\bTunisia\b|\bTurkey\b|\bTurkmenistan\b|\bTuvalu\b|\bUganda\b|\bUkraine\b|\bUnited Arab Emirates\b|\bUnited Kingdom\b|\bUruguay\b|\bUzbekistan\b|\bVanuatu\b|\bVatican City\b|\bVenezuela\b|\bVietnam\b|\bYemen\b|\bZambia\b|\bZimbabwe\b|\bEngland\b|\bScotland\b|\bWales\b|\bBritain\b|\bU\.? ?K\.?\b|\bU\.? ?A\.? ?E\.?\b'
	
	us_pattern = r'\b(United States|U\.? ?S\.? ?A\.?|[Uu]\. ?[Ss]\.?|America)\b'
	
	entire_str_pattern = r'^(US|AL|CO|DE|HI|IN|LA|ME|MI|OH|OK|OR)$'
	
	states_abbrev_pattern = r'\b(AK|AR|AZ|CA|CT|FL|GA|IA|ID|IL|KS|KY|MA|MD|MN|MO|MS|MT|NC|ND|NE|NH|NJ|NM|NV|NY|PA|RI|SC|SD|TN|TX|UT|VA|VT|WA|WI|WV|WY)\b'
	
	us_city_abbrev_pattern = r'\b(ATL|HTX|D\.? ?C\.? ?|STL|ATX|PNW|NOLA|KCMO|DTX|CLE|SATX)\b'
	
	us_cities_pattern = r'\b(New York City|Los Angeles|Chicago|Houston|Philadelphia|Phoenix|San Antonio|San Diego|Dallas|San Jose|Austin|Indianapolis|Jacksonville|San Francisco|Columbus|Charlotte|Fort Worth|Detroit|El Paso|Memphis|Seattle|Denver|Boston|Nashville|Baltimore|Louisville|Portland|Vegas|Milwaukee|Albuquerque|Tucson|Fresno|Sacramento|Long Beach|Mesa|Atlanta|Omaha|Raleigh|Miami|Oakland|Minneapolis|Tulsa|Cleveland|Wichita|Arlington|N.? ?Y.? ?C.? ?|Brooklyn|Bronx|Staten Island|Queens|Manhattan|Pittsburgh|New Orleans|Philly|Cincinnati|St\\.? Louis|Hollywood|Salt Lake City|Anchorage|Fort Lauderdale|City of Angels|Buffalo|Tampa|Bakersfield|Aurora|Anaheim|Honolulu|Santa Ana|Corpus Christi|Lexington|St\\.? Paul|Cincinnati|Greensboro|Anchorage|Plano|Orlando|Irvine|Newark|Toledo|Durham|Chula Vista|Fort Wayne|Jersey City|Laredo|Lubbock|Scottsdale|Reno|Chesapeake|Fremont|Boise|Baton Rouge|Spokane)\b'
	
	us_region_pattern = r'\b(East Coast|Long Island|Bay Area|Silicon Valley|West Coast|South Jersey|Cali|So ?Cal)\b'
	
	area_code_pattern = r'\b201\b|\b202\b|\b203\b|\b205\b|\b206\b|\b207\b|\b208\b|\b209\b|\b210\b|\b212\b|\b213\b|\b214\b|\b215\b|\b216\b|\b217\b|\b218\b|\b219\b|\b220\b|\b223\b|\b224\b|\b225\b|\b228\b|\b229\b|\b231\b|\b234\b|\b239\b|\b240\b|\b248\b|\b251\b|\b252\b|\b253\b|\b254\b|\b256\b|\b260\b|\b262\b|\b267\b|\b269\b|\b270\b|\b272\b|\b276\b|\b279\b|\b281\b|\b301\b|\b302\b|\b303\b|\b304\b|\b305\b|\b307\b|\b308\b|\b309\b|\b310\b|\b312\b|\b313\b|\b314\b|\b315\b|\b316\b|\b317\b|\b318\b|\b319\b|\b320\b|\b321\b|\b323\b|\b325\b|\b330\b|\b331\b|\b332\b|\b334\b|\b336\b|\b337\b|\b339\b|\b341\b|\b346\b|\b347\b|\b351\b|\b352\b|\b360\b|\b361\b|\b364\b|\b380\b|\b385\b|\b386\b|\b401\b|\b402\b|\b405\b|\b406\b|\b407\b|\b408\b|\b409\b|\b410\b|\b412\b|\b413\b|\b414\b|\b415\b|\b417\b|\b419\b|\b423\b|\b424\b|\b425\b|\b430\b|\b432\b|\b434\b|\b435\b|\b440\b|\b442\b|\b443\b|\b445\b|\b458\b|\b463\b|\b469\b|\b470\b|\b475\b|\b478\b|\b479\b|\b480\b|\b484\b|\b501\b|\b502\b|\b503\b|\b504\b|\b505\b|\b507\b|\b508\b|\b509\b|\b510\b|\b512\b|\b513\b|\b515\b|\b516\b|\b517\b|\b518\b|\b520\b|\b530\b|\b531\b|\b534\b|\b539\b|\b540\b|\b541\b|\b551\b|\b559\b|\b561\b|\b562\b|\b563\b|\b564\b|\b567\b|\b570\b|\b571\b|\b573\b|\b574\b|\b575\b|\b580\b|\b585\b|\b586\b|\b601\b|\b602\b|\b603\b|\b605\b|\b606\b|\b607\b|\b608\b|\b609\b|\b610\b|\b612\b|\b614\b|\b615\b|\b616\b|\b617\b|\b618\b|\b619\b|\b620\b|\b623\b|\b626\b|\b628\b|\b629\b|\b630\b|\b631\b|\b636\b|\b640\b|\b641\b|\b646\b|\b650\b|\b651\b|\b657\b|\b660\b|\b661\b|\b662\b|\b667\b|\b669\b|\b671\b|\b678\b|\b680\b|\b681\b|\b682\b|\b684\b|\b689\b|\b701\b|\b702\b|\b703\b|\b704\b|\b706\b|\b707\b|\b708\b|\b712\b|\b713\b|\b714\b|\b715\b|\b716\b|\b717\b|\b718\b|\b719\b|\b720\b|\b724\b|\b725\b|\b726\b|\b727\b|\b731\b|\b732\b|\b734\b|\b737\b|\b740\b|\b743\b|\b747\b|\b754\b|\b757\b|\b760\b|\b762\b|\b763\b|\b765\b|\b769\b|\b770\b|\b772\b|\b773\b|\b774\b|\b775\b|\b779\b|\b781\b|\b785\b|\b786\b|\b801\b|\b802\b|\b803\b|\b804\b|\b805\b|\b806\b|\b808\b|\b810\b|\b812\b|\b813\b|\b814\b|\b815\b|\b816\b|\b817\b|\b818\b|\b820\b|\b828\b|\b830\b|\b831\b|\b832\b|\b838\b|\b843\b|\b845\b|\b847\b|\b848\b|\b850\b|\b854\b|\b856\b|\b857\b|\b858\b|\b859\b|\b860\b|\b862\b|\b863\b|\b864\b|\b865\b|\b870\b|\b872\b|\b878\b|\b901\b|\b903\b|\b904\b|\b906\b|\b907\b|\b908\b|\b909\b|\b910\b|\b912\b|\b913\b|\b914\b|\b915\b|\b916\b|\b917\b|\b918\b|\b919\b|\b920\b|\b925\b|\b928\b|\b929\b|\b930\b|\b931\b|\b934\b|\b936\b|\b937\b|\b938\b|\b940\b|\b941\b|\b947\b|\b949\b|\b951\b|\b952\b|\b954\b|\b956\b|\b959\b|\b970\b|\b971\b|\b972\b|\b973\b|\b978\b|\b979\b|\b980\b|\b984\b|\b985\b|\b986\b|\b989\b'
	
	if re.search(new_england, location, re.U | re.I):
		return True
	elif re.search(countries_pattern, location, re.U | re.I):
		return False
	elif re.search(us_pattern, location, re.U | re.I):
		return True
	elif re.search(states_pattern, location, re.U | re.I):
		return True
	elif re.search(entire_str_pattern, location, re.U | re.I):
		return True
	elif re.search(states_abbrev_pattern, location, re.U | re.I):
		return True
	elif re.search(us_cities_pattern, location, re.U | re.I):
		return True
	elif re.search(us_city_abbrev_pattern, location, re.U | re.I):
		return True
	elif re.search(area_code_pattern, location, re.U | re.I):
		return True
	else:
		return False

##### End code for function to filter to US location strings. #####
