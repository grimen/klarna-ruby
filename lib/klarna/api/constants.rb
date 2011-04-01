# encoding: utf-8

module Klarna
  module API
    module Constants

      # -----------------------------------------------------------------------
      #  API
      # -----------------------------------------------------------------------
      END_POINT = {
        :test => {
          :protocol => 'http',
          :host => 'beta-test.klarna.com',
          :port => 4567
        },
        :production => {
          :protocol => 'https',
          :host => 'payment.klarna.com',
          :port => 80 # TODO: For SSL, port 4568 should be used
        }
      }.freeze

      PROTOCOL_ENCODING = 'iso-8859-1'.freeze
      PROTOCOL_VERSION = '4.0'.freeze

      # -----------------------------------------------------------------------
      #  General
      # -----------------------------------------------------------------------
      AVERAGE_INTEREST_PERIOD = 45.freeze
      DAYS_IN_A_YEAR = 365.25.freeze

      # -----------------------------------------------------------------------
      #  Mode: Defaults
      # -----------------------------------------------------------------------
      DEFAULTS = {
        :OCR      => '',
        :PCLASS   => -1,
        :YSALARY  => 0
      }.freeze

      # -----------------------------------------------------------------------
      #  Flags: Campaign Type
      # -----------------------------------------------------------------------
      PCLASS = {
        :NONE     => -1,
        :ANNUITY  => 0,
        :DIVISOR  => 1
      }.freeze

      # -----------------------------------------------------------------------
      #  Flags: Mobile
      # -----------------------------------------------------------------------
      MOBILE = {
        :PRESERVE_RESERVATION => 16,
        :PHONE_TRANSACTION    => 512,
        :SEND_PHONE_PIN       => 1024
      }.freeze

      # -----------------------------------------------------------------------
      #  Flags: Invoice
      # -----------------------------------------------------------------------
      INVOICE = {
        :AUTO_ACTIVATE        => 1,
        :TEST_MODE            => 2,
        :MANUAL_AUTO_ACTIVATE => 4,
        :PRE_PAY              => 8,
        :DELAYED_PAY          => 16
      }.freeze

      # -----------------------------------------------------------------------
      #  Flags: Goods
      # -----------------------------------------------------------------------
      GOODS = {
        :PRINT_1000   => 1,
        :PRINT_100    => 2,
        :PRINT_10     => 4,
        :IS_SHIPMENT  => 8,
        :IS_HANDLING  => 16,
        :INC_VAT      => 32
      }.freeze

      # -----------------------------------------------------------------------
      #  Flags: Monthly Cost
      # -----------------------------------------------------------------------
      MONTHLY_COST = {
        :LIMIT  => 0,
        :ACTUAL => 1
      }.freeze

      # -----------------------------------------------------------------------
      #  Mode: Shipment Type (add_invoice)
      # -----------------------------------------------------------------------
      SHIPMENT_TYPES = {
        :NORMAL  => 1,
        :EXPRESS => 2
      }.freeze

      # -----------------------------------------------------------------------
      #  Mode: Charge Type (update_charge_amount)
      # -----------------------------------------------------------------------
      CHARGE_TYPES = {
        :SHIPMENT => 1,
        :HANDLING => 2
      }.freeze

      # -----------------------------------------------------------------------
      #  Mode: Address Type
      # -----------------------------------------------------------------------
      ADDRESS_FORMATS = {
        :OLD    => 1,
        :NEW    => 2,
        :GIVEN  => 5
      }.freeze

      # -----------------------------------------------------------------------
      #  Mode: Personal Number Encodings (SSN)
      # -----------------------------------------------------------------------
      PNO_FORMATS = {
        :FAKE => 1,
        :SE   => 2, # valid: yymmdd-nnnn, yymmddnnnn, yyyymmdd-nnnn, yyyymmddnnnn
        :NO   => 3, # valid: ddmmyynnnnn
        :FI   => 4, # valid: ddmmyy-nnnn, ddmmyynnnn
        :DK   => 5, # valid: ddmmyynnnn
        :DE   => 6, # valid: ?
        :NL   => 7, # valid: ?
        :CNO  => 1000
      }.freeze

      # -----------------------------------------------------------------------
      #  Mode: Currencies
      # -----------------------------------------------------------------------
      CURRENCIES = {
        :SEK => 0,
        :NOK => 1,
        :EUR => 2,
        :DKK => 3
      }.freeze

      # -----------------------------------------------------------------------
      #  Mode: Country (ISO3166)
      # -----------------------------------------------------------------------
      COUNTRIES = {
        :AF => 1,  # AFGHANISTAN
        :AX => 2,  # ÅLAND ISLANDS
        :AL => 3,  # ALBANIA
        :DZ => 4,  # ALGERIA
        :AS => 5,  # AMERICAN SAMOA
        :AD => 6,  # ANDORRA
        :AO => 7,  # ANGOLA
        :AI => 8,  # ANGUILLA
        :AQ => 9,  # ANTARCTICA
        :AG => 10, # ANTIG. A. BARBUDA
        :AR => 11, # ARGENTINA
        :AM => 12, # ARMENIA
        :AW => 13, # ARUBA
        :AU => 14, # AUSTRALIA
        :AT => 15, # AUSTRIA
        :AZ => 16, # AZERBAIJAN
        :BS => 17, # BAHAMAS
        :BH => 18, # BAHRAIN
        :BD => 19, # BANGLADESH
        :BB => 20, # BARBADOS
        :BY => 21, # BELARUS
        :BE => 22, # BELGIUM
        :BZ => 23, # BELIZE
        :BJ => 24, # BENIN
        :BM => 25, # BERMUDA
        :BT => 26, # BHUTAN
        :BO => 27, # BOLIVIA
        :BA => 28, # BOS. A. HERZEGOV.
        :BW => 29, # BOTSWANA
        :BV => 30, # BOUVET ISLAND
        :BR => 31, # BRAZIL
        :IO => 32, # BR. IND. O.T.
        :BN => 33, # BRUNEI DARUSSALAM
        :BG => 34, # BULGARIA
        :BF => 35, # BURKINA FASO
        :BI => 36, # BURUNDI
        :KH => 37, # CAMBODIA
        :CM => 38, # CAMEROON
        :CA => 39, # CANADA
        :CV => 40, # CAPE VERDE
        :KY => 41, # CAYMAN ISLANDS
        :CF => 42, # C.A.R.
        :TD => 43, # CHAD
        :CL => 44, # CHILE
        :CN => 45, # CHINA
        :CX => 46, # CHRISTMAS ISLAND
        :CC => 47, # COCOS ISLANDS
        :CO => 48, # COLOMBIA
        :KM => 49, # COMOROS
        :CG => 50, # CONGO
        :CD => 51, # CONGO
        :CK => 52, # COOK ISLANDS
        :CR => 53, # COSTA RICA
        :CI => 54, # COTE D'IVOIRE
        :HR => 55, # CROATIA
        :CU => 56, # CUBA
        :CY => 57, # CYPRUS
        :CZ => 58, # CZECH REPUBLIC
        :DK => 59, # DENMARK
        :DJ => 60, # DJIBOUTI
        :DM => 61, # DOMINICA
        :DO => 62, # DOMINICAN REPUBLIC
        :EC => 63, # ECUADOR
        :EG => 64, # EGYPT
        :SV => 65, # EL SALVADOR
        :GQ => 66, # EQUATORIAL GUINEA
        :ER => 67, # ERITREA
        :EE => 68, # ESTONIA
        :ET => 69, # ETHIOPIA
        :FK => 70, # FALKLAND ISLANDS
        :FO => 71, # FAROE ISLANDS
        :FJ => 72, # FIJI
        :FI => 73, # FINLAND
        :FR => 74, # FRANCE
        :GF => 75, # FRENCH GUIANA
        :PF => 76, # FRENCH POLYNESIA
        :TF => 77, # FR.S. TERRITORIES
        :GA => 78, # GABON
        :GM => 79, # GAMBIA
        :GE => 80, # GEORGIA
        :DE => 81, # GERMANY
        :GH => 82, # GHANA
        :GI => 83, # GIBRALTAR
        :GR => 84, # GREECE
        :GL => 85, # GREENLAND
        :GD => 86, # GRENADA
        :GP => 87, # GUADELOUPE
        :GU => 88, # GUAM
        :GT => 89, # GUATEMALA
        :GG => 90, # GUERNSEY
        :GN => 91, # GUINEA
        :GW => 92, # GUINEA-BISSAU
        :GY => 93, # GUYANA
        :HT => 94, # HAITI
        :HM => 95, # HEARD A. MCD ISL.
        :VA => 96, # HOLY SEE
        :HN => 97, # HONDURAS
        :HK => 98, # HONG KONG
        :HU => 99, # HUNGARY
        :IS => 100, # ICELAND
        :IN => 101, # INDIA
        :ID => 102, # INDONESIA
        :IR => 103, # IRAN
        :IQ => 104, # IRAQ
        :IE => 105, # IRELAND
        :IM => 106, # ISLE OF MAN
        :IL => 107, # ISRAEL
        :IT => 108, # ITALY
        :JM => 109, # JAMAICA
        :JP => 110, # JAPAN
        :JE => 111, # JERSEY
        :JO => 112, # JORDAN
        :KZ => 113, # KAZAKHSTAN
        :KE => 114, # KENYA
        :KI => 115, # KIRIBATI
        :KP => 116, # KOREA, D.P.R OF
        :KR => 117, # KOREA, R. OF
        :KW => 118, # KUWAIT
        :KG => 119, # KYRGYZSTAN
        :LA => 120, # LAO P.D.R
        :LV => 121, # LATVIA
        :LB => 122, # LEBANON
        :LS => 123, # LESOTHO
        :LR => 124, # LIBERIA
        :LY => 125, # LIBYAN A.J.
        :LI => 126, # LIECHTENSTEIN
        :LT => 127, # LITHUANIA
        :LU => 128, # LUXEMBOURG
        :MO => 129, # MACAO
        :MK => 130, # MACEDONIA
        :MG => 131, # MADAGASCAR
        :MW => 132, # MALAWI
        :MY => 133, # MALAYSIA
        :MV => 134, # MALDIVES
        :ML => 135, # MALI
        :MT => 136, # MALTA
        :MH => 137, # MARSHALL ISLANDS
        :MQ => 138, # MARTINIQUE
        :MR => 139, # MAURITANIA
        :MU => 140, # MAURITIUS
        :YT => 141, # MAYOTTE
        :MX => 142, # MEXICO
        :FM => 143, # MICRONESIA
        :MD => 144, # MOLDOVA
        :MC => 145, # MONACO
        :MN => 146, # MONGOLIA
        :MS => 147, # MONTSERRAT
        :MA => 148, # MOROCCO
        :MZ => 149, # MOZAMBIQUE
        :MM => 150, # MYANMAR
        :NA => 151, # NAMIBIA
        :NR => 152, # NAURU
        :NP => 153, # NEPAL
        :NL => 154, # NETHERLANDS
        :AN => 155, # NETH. ANTILLES
        :NC => 156, # NEW CALEDONIA
        :NZ => 157, # NEW ZEALAND
        :NI => 158, # NICARAGUA
        :NE => 159, # NIGER
        :NG => 160, # NIGERIA
        :NU => 161, # NIUE
        :NF => 162, # NORFOLK ISLAND
        :MP => 163, # N.MARIANA ISLANDS
        :NO => 164, # NORWAY
        :OM => 165, # OMAN
        :PK => 166, # PAKISTAN
        :PW => 167, # PALAU
        :PS => 168, # PALESTINIAN T.O
        :PA => 169, # PANAMA
        :PG => 170, # PAPUA NEW GUINEA
        :PY => 171, # PARAGUAY
        :PE => 172, # PERU
        :PH => 173, # PHILIPPINES
        :PN => 174, # PITCAIRN
        :PL => 175, # POLAND
        :PT => 176, # PORTUGAL
        :PR => 177, # PUERTO RICO
        :QA => 178, # QATAR
        :RE => 179, # REUNION
        :RO => 180, # ROMANIA
        :RU => 181, # RUSSIAN FED.
        :RW => 182, # RWANDA
        :SH => 183, # SAINT HELENA
        :KN => 184, # ST KITTS A. NEVIS
        :LC => 185, # SAINT LUCIA
        :PM => 186, # ST P A MIQUELON
        :VC => 187, # ST V A THE GRENA.
        :WS => 188, # SAMOA
        :SM => 189, # SAN MARINO
        :ST => 190, # S.TOME A PRINCIPE
        :SA => 191, # SAUDI ARABIA
        :SN => 192, # SENEGAL
        :CS => 193, # SERB. A. MONTE.
        :SC => 194, # SEYCHELLES
        :SL => 195, # SIERRA LEONE
        :SG => 196, # SINGAPORE
        :SK => 197, # SLOVAKIA
        :SI => 198, # SLOVENIA
        :SB => 199, # SOLOMON ISLANDS
        :SO => 200, # SOMALIA
        :ZA => 201, # SOUTH AFRICA
        :GS => 202, # S.GEORGIA ATSSI
        :ES => 203, # SPAIN
        :LK => 204, # SRI LANKA
        :SD => 205, # SUDAN
        :SR => 206, # SURINAME
        :SJ => 207, # SVALB. A J.MAYEN
        :SZ => 208, # SWAZILAND
        :SE => 209, # SWEDEN
        :CH => 210, # SWITZERLAND
        :SY => 211, # SYRIAN A.R
        :TW => 212, # TAIWAN P.O. CHINA
        :TJ => 213, # TAJIKISTAN
        :TZ => 214, # TANZANIA
        :TH => 215, # THAILAND
        :TL => 216, # TIMOR-LESTE
        :TG => 217, # TOGO
        :TK => 218, # TOKELAU
        :TO => 219, # TONGA
        :TT => 220, # TR. AND TOBAGO
        :TN => 221, # TUNISIA
        :TR => 222, # TURKEY
        :TM => 223, # TURKMENISTAN
        :TC => 224, # T. A CAICOS ISL.
        :TV => 225, # TUVALU
        :UG => 226, # UGANDA
        :UA => 227, # UKRAINE
        :AE => 228, # U.A.E
        :GB => 229, # UNITED KINGDOM
        :US => 230, # UNITED STATES
        :UM => 231, # US M.O. ISLANDS
        :UY => 232, # URUGUAY
        :UZ => 233, # UZBEKISTAN
        :VU => 234, # VANUATU
        :VE => 235, # VENEZUELA
        :VN => 236, # VIET NAM
        :VG => 237, # VIRGIN ISLANDS BR
        :VI => 238, # VIRGIN ISLANDS US
        :WF => 239, # WALLIS AND FUTUNA
        :EH => 240, # WESTERN SAHARA
        :YE => 241, # YEMEN
        :ZM => 242, # ZAMBIA
        :ZW => 243  # ZIMBABWE
      }.freeze

      # -----------------------------------------------------------------------
      #  Mode: Language (ISO639)
      # -----------------------------------------------------------------------
      LANGUAGES = {
        :AA => 1,   #  Afar
        :AB => 2,   #  Abkhazian
        :AE => 3,   #  Avestan
        :AF => 4,   #  Afrikaans
        :AM => 5,   #  Amharic
        :AR => 6,   #  Arabic
        :AS => 7,   #  Assamese
        :AY => 8,   #  Aymara
        :AZ => 9,   #  Azerbaijani
        :BA => 10,  #  Bashkir
        :BE => 11,  #  Belarusian
        :BG => 12,  #  Bulgarian
        :BH => 13,  #  Bihari
        :BI => 14,  #  Bislama
        :BN => 15,  #  Bengali; Bangla
        :BO => 16,  #  Tibetan
        :BR => 17,  #  Breton
        :BS => 18,  #  Bosnian
        :CA => 19,  #  Catalan
        :CE => 20,  #  Chechen
        :CH => 21,  #  Chamorro
        :CO => 22,  #  Corsican
        :CS => 23,  #  Czech
        :CU => 24,  #  Church Slavic
        :CV => 25,  #  Chuvash
        :CY => 26,  #  Welsh
        :DA => 27,  #  Danish
        :DE => 28,  #  German
        :DZ => 29,  #  Dzongkha; Bhutani
        :EL => 30,  #  Greek
        :EN => 31,  #  English
        :EO => 32,  #  Esperanto
        :ES => 33,  #  Spanish
        :ET => 34,  #  Estonian
        :EU => 35,  #  Basque
        :FA => 36,  #  Persian
        :FI => 37,  #  Finnish
        :FJ => 38,  #  Fijian; Fiji
        :FO => 39,  #  Faroese
        :FR => 40,  #  French
        :FY => 41,  #  Frisian
        :GA => 42,  #  Irish
        :GD => 43,  #  Scots; Gaelic
        :GL => 44,  #  Gallegan; Galician
        :GN => 45,  #  Guarani
        :GU => 46,  #  Gujarati
        :GV => 47,  #  Manx
        :HA => 48,  #  Hausa (?)
        :HE => 49,  #  Hebrew
        :HI => 50,  #  Hindi
        :HO => 51,  #  Hiri Motu
        :HR => 52,  #  Croatian
        :HU => 53,  #  Hungarian
        :HY => 54,  #  Armenian
        :HZ => 55,  #  Herero
        :IA => 56,  #  Interlingua
        :ID => 57,  #  Indonesian
        :IE => 58,  #  Interlingue
        :IK => 59,  #  Inupiak
        :IO => 60,  #  Ido
        :IS => 61,  #  Icelandic
        :IT => 62,  #  Italian
        :IU => 63,  #  Inuktitut
        :JA => 64,  #  Japanese
        :JV => 65,  #  Javanese
        :KA => 66,  #  Georgian
        :KI => 67,  #  Kikuyu
        :KJ => 68,  #  Kuanyama
        :KK => 69,  #  Kazakh
        :KL => 70,  #  Kalaallisut
        :KM => 71,  #  Khmer; Cambodian
        :KN => 72,  #  Kannada
        :KO => 73,  #  Korean
        :KS => 74,  #  Kashmiri
        :KU => 75,  #  Kurdish
        :KV => 76,  #  Komi
        :KW => 77,  #  Cornish
        :KY => 78,  #  Kirghiz
        :LA => 79,  #  Latin
        :LB => 80,  #  Letzeburgesch
        :LN => 81,  #  Lingala
        :LO => 82,  #  Lao; Laotian
        :LT => 83,  #  Lithuanian
        :LV => 84,  #  Latvian; Lettish
        :MG => 85,  #  Malagasy
        :MH => 86,  #  Marshall
        :MI => 87,  #  Maori
        :MK => 88,  #  Macedonian
        :ML => 89,  #  Malayalam
        :MN => 90,  #  Mongolian
        :MO => 91,  #  Moldavian
        :MR => 92,  #  Marathi
        :MS => 93,  #  Malay
        :MT => 94,  #  Maltese
        :MY => 95,  #  Burmese
        :NA => 96,  #  Nauru
        :NB => 97,  #  Norwegian Bokmål
        :ND => 98,  #  Ndebele, North
        :NE => 99,  #  Nepali
        :NG => 100, #  Ndonga
        :NL => 101, #  Dutch
        :NN => 102, #  Norwegian Nynorsk
        :NO => 103, #  Norwegian
        :NR => 104, #  Ndebele, South
        :NV => 105, #  Navajo
        :NY => 106, #  Chichewa; Nyanja
        :OC => 107, #  Occitan; Provençal
        :OM => 108, #  (Afan) Oromo
        :OR => 109, #  Oriya
        :OS => 110, #  Ossetian; Ossetic
        :PA => 111, #  Panjabi; Punjabi
        :PI => 112, #  Pali
        :PL => 113, #  Polish
        :PS => 114, #  Pashto, Pushto
        :PT => 115, #  Portuguese
        :QU => 116, #  Quechua
        :RM => 117, #  Rhaeto-Romance
        :RN => 118, #  Rundi; Kirundi
        :RO => 119, #  Romanian
        :RU => 120, #  Russian
        :RW => 121, #  Kinyarwanda
        :SA => 122, #  Sanskrit
        :SC => 123, #  Sardinian
        :SD => 124, #  Sindhi
        :SE => 125, #  Northern Sami
        :SG => 126, #  Sango; Sangro
        :SI => 127, #  Sinhalese
        :SK => 128, #  Slovak
        :SL => 129, #  Slovenian
        :SM => 130, #  Samoan
        :SN => 131, #  Shona
        :SO => 132, #  Somali
        :SQ => 133, #  Albanian
        :SR => 134, #  Serbian
        :SS => 135, #  Swati; Siswati
        :ST => 136, #  Sesotho
        :SU => 137, #  Sundanese
        :SV => 138, #  Swedish
        :SW => 139, #  Swahili
        :TA => 140, #  Tamil
        :TE => 141, #  Telugu
        :TG => 142, #  Tajik
        :TH => 143, #  Thai
        :TI => 144, #  Tigrinya
        :TK => 145, #  Turkmen
        :TL => 146, #  Tagalog
        :TN => 147, #  Tswana; Setswana
        :TO => 148, #  Tonga (?)
        :TR => 149, #  Turkish
        :TS => 150, #  Tsonga
        :TT => 151, #  Tatar
        :TW => 152, #  Twi
        :TY => 153, #  Tahitian
        :UG => 154, #  Uighur
        :UK => 155, #  Ukrainian
        :UR => 156, #  Urdu
        :UZ => 157, #  Uzbek
        :VI => 158, #  Vietnamese
        :VO => 159, #  Volapuk
        :WA => 160, #  Walloon
        :WO => 161, #  Wolof
        :XH => 162, #  Xhosa
        :YI => 163, #  Yiddish
        :YO => 164, #  Yoruba
        :ZA => 165, #  Zhuang
        :ZH => 166, #  Chinese
        :ZU => 167  #  Zulu
      }.freeze

      # -----------------------------------------------------------------------
      #  Mode: Interest Rates (TODO: Remove - deprecated?)
      # -----------------------------------------------------------------------
      INTEREST_RATES = {
        :SE => 19.50,
        :NO => 22.00,
        :DK => 21.60,
        :FI => 22.00,
        :DE => 14.95,
        :NL => 14.95
      }.freeze

      # -----------------------------------------------------------------------
      #  Amounts
      # -----------------------------------------------------------------------

      LOWEST_PAYMENT_BY_COUNTRY = {
        :SE => 5000.00,
        :NO => 9500.00,
        :FI => 895.00,
        :DK => 8900.00,
        :DE => 695.00,
        :NL => 500.00
      }.freeze

      # TODO: Remove - deprecated?
      LOWEST_PAYMENT_BY_CURRENCY = {
        CURRENCIES[:SEK] => 5000.00,
        CURRENCIES[:NOK] => 9500.00,
        CURRENCIES[:EUR] => 895.00,
        CURRENCIES[:DKK] => 8900.00
      }.freeze

      # -----------------------------------------------------------------------
      #  Country defaults
      # -----------------------------------------------------------------------
      COUNTRY_DEFAULTS = {
        :SE => {
          :country  => COUNTRIES[:SE],
          :lang     => LANGUAGES[:SV],
          :currency => CURRENCIES[:SEK],
          :pno      => PNO_FORMATS[:SE]
        },
        :NO => {
          :country  => COUNTRIES[:NO],
          :lang     => LANGUAGES[:NO],
          :currency => CURRENCIES[:NOK],
          :pno      => PNO_FORMATS[:NO]
        },
        :DK => {
          :country  => COUNTRIES[:DK],
          :lang     => LANGUAGES[:DA],
          :currency => CURRENCIES[:DKK],
          :pno      => PNO_FORMATS[:DK]
        },
        :FI => {
          :country  => COUNTRIES[:FI],
          :lang     => LANGUAGES[:FI],
          :currency => CURRENCIES[:EUR],
          :pno      => PNO_FORMATS[:FI]
        },
        :DE => {
          :country  => COUNTRIES[:DE],
          :lang     => LANGUAGES[:DE],
          :currency => CURRENCIES[:EUR],
          :pno      => PNO_FORMATS[:DE]
        },
        :NL => {
          :country  => COUNTRIES[:NL],
          :lang     => LANGUAGES[:NL],
          :currency => CURRENCIES[:EUR],
          :pno      => PNO_FORMATS[:NL]
        }
      }.freeze

    end
  end
end
