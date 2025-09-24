// ============================================================================
// LOCALIZATION SERVICE - MULTI-LANGUAGE SUPPORT
// ============================================================================
// This service manages translations for English, Russian, and Turkmen languages.
// Features: Language switching, text translations, locale management
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  String _currentLanguage = 'en';
  
  String get currentLanguage => _currentLanguage;
  
  // Language mappings
  static const Map<String, String> _languageNames = {
    'en': 'English',
    'ru': 'Russian', 
    'tk': 'Turkmen',
  };
  
  static const Map<String, String> _nativeNames = {
    'en': 'English',
    'ru': 'Русский',
    'tk': 'Türkmen',
  };
  
  // Translations
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // App
      'app_title': 'TizGo',
      'service': 'Service',
      'tassykla': 'Submit',
      'loading': 'Loading...',
      
      // Service Types
      'city': 'Ashgabat',
      'inter_city': 'Region',
      'select_service_type': 'Select Service Type',
      
      // Pickup & Delivery
      'pickup_location': 'Pickup Location',
      'delivery_location': 'Delivery Location',
      'select_pickup_location': 'Select Pickup Location',
      'select_delivery_location': 'Select Delivery Location',
      'select_pickup_first': 'Select pickup first',
      'select': 'Select',
      'how_do_we_collect': 'How do we collect the parcel from you?',
      'where_do_we_deliver': 'Where do we deliver the parcel?',
      'drop_off_easybox': 'Drop-off at office',
      'load_parcel_locker': 'Load your parcel at any locker near you',
      'pickup_from_address': 'Pick-up from address',
      'courier_collect_address': 'The courier will collect the parcel from your address',
      'delivery_to_easybox': 'Delivery to office',
      'parcel_handover_easybox': 'Parcel handover to courier and delivery to any office in the country',
      'delivery_to_address': 'Delivery to address',
      'courier_deliver_address': 'The courier will deliver the parcel to the specified address',
      'continue': 'Continue',
      
      // Form Fields
      'sender_name': 'Sender Full Name',
      'sender_phone': 'Sender Phone Number',
      'recipient_name': 'Recipient Full Name',
      'recipient_phone': 'Recipient Phone Number',
      'package_info': 'Package Information',
      'package_info_hint': 'Describe your package...',
      
      // Buttons
      'create_delivery': 'Create Delivery',
      'profile': 'Profile',
      'help_support': 'Help & Support',
      'logout': 'Logout',
      'language': 'Language',
      'cancel': 'Cancel',
      'ok': 'OK',
      'save': 'Save',
      'edit': 'Edit',
      'edit_field': 'Edit',
      
      // Validation
      'please_select_pickup': 'Please select a pickup location',
      'please_select_delivery': 'Please select a delivery location',
      'please_enter_sender_name': 'Please enter sender name',
      'please_enter_recipient_name': 'Please enter recipient name',
      'please_enter_phone': 'Please enter phone number',
      'phone_8_digits': 'Phone number must be exactly 8 digits',
      'please_enter_package_info': 'Please enter package information',
      
      // Success/Error Messages
      'delivery_created': 'Delivery created successfully!',
      'language_changed': 'Language changed to',
      'logged_out': 'Logged out successfully',
      'phone_updated': 'Phone number updated successfully',
      'full_name_updated': 'Full name updated successfully',
      'field_updated': 'updated successfully',
      
      // Network
      'no_internet': 'No Internet Connection',
      'check_connection': 'Please check your internet connection and try again. You need to be online to submit delivery requests.',
      
      // Help & Support
      'need_help': 'Need help? Contact our support team:',
      'call_support': 'Call Support',
      'whatsapp_support': 'WhatsApp Support',
      
      // Orders
      'my_orders': 'My Orders',
      'delivery_id': 'Delivery #',
      'from': 'From',
      'to': 'To',
      'recipient': 'Recipient',
      'no_deliveries_yet': 'No deliveries yet',
      'create_first_delivery': 'Create your first delivery to get started',
      'created_date': 'Created Date',
      'service_information': 'Service Information',
      'address_information': 'Address Information',
      'pickup_type': 'Pickup Type',
      'delivery_type': 'Delivery Type',
      'service_type': 'Service Type',
      'city_delivery': 'City Delivery',
      'inter_city_delivery': 'Inter-City Delivery',
      'easybox': 'Office',
      'address': 'Address',
      'sender_information': 'Sender Information',
      'recipient_information': 'Recipient Information',
      'package_information': 'Package Information',
      'description': 'Description',
      'price': 'Price',
      'manat': 'manat',
      
      // Profile
      'phone_number': 'Phone Number',
      'full_name': 'Full Name',
      'delivery_service': 'Delivery Service',
      'are_you_sure_logout': 'Are you sure you want to logout?',
      'select_language': 'Select Language',
      
      // Navigation
      'home': 'Home',
    },
    'ru': {
      // App
      'app_title': 'TizGo',
      'service': 'Сервис',
      'tassykla': 'Подтвердить',
      'loading': 'Загрузка...',
      
      // Service Types
      'city': 'Ашхабад',
      'inter_city': 'Регион',
      'select_service_type': 'Выберите тип услуги',
      
      // Pickup & Delivery
      'pickup_location': 'Место получения',
      'delivery_location': 'Место доставки',
      'select_pickup_location': 'Выберите место получения',
      'select_delivery_location': 'Выберите место доставки',
      'select_pickup_first': 'Сначала выберите место получения',
      'select': 'Выбрать',
      'how_do_we_collect': 'Как мы заберем у вас посылку?',
      'where_do_we_deliver': 'Куда мы доставим посылку?',
      'drop_off_easybox': 'Сдать в офис',
      'load_parcel_locker': 'Поместите посылку в любой шкафчик рядом с вами',
      'pickup_from_address': 'Забрать по адресу',
      'courier_collect_address': 'Курьер заберет посылку с вашего адреса',
      'delivery_to_easybox': 'Доставка в офис',
      'parcel_handover_easybox': 'Передача посылки курьеру и доставка в любой офис в стране',
      'delivery_to_address': 'Доставка по адресу',
      'courier_deliver_address': 'Курьер доставит посылку по указанному адресу',
      'continue': 'Продолжить',
      
      // Form Fields
      'sender_name': 'Имя отправителя',
      'sender_phone': 'Телефон отправителя',
      'recipient_name': 'Имя получателя',
      'recipient_phone': 'Телефон получателя',
      'package_info': 'Информация о посылке',
      'package_info_hint': 'Опишите вашу посылку...',
      
      // Buttons
      'create_delivery': 'Создать доставку',
      'profile': 'Профиль',
      'help_support': 'Помощь и поддержка',
      'logout': 'Выйти',
      'language': 'Язык',
      'cancel': 'Отмена',
      'ok': 'ОК',
      'save': 'Сохранить',
      'edit': 'Редактировать',
      'edit_field': 'Редактировать',
      
      // Validation
      'please_select_pickup': 'Пожалуйста, выберите место получения',
      'please_select_delivery': 'Пожалуйста, выберите место доставки',
      'please_enter_sender_name': 'Пожалуйста, введите имя отправителя',
      'please_enter_recipient_name': 'Пожалуйста, введите имя получателя',
      'please_enter_phone': 'Пожалуйста, введите номер телефона',
      'phone_8_digits': 'Номер телефона должен содержать ровно 8 цифр',
      'please_enter_package_info': 'Пожалуйста, введите информацию о посылке',
      
      // Success/Error Messages
      'delivery_created': 'Доставка создана успешно!',
      'language_changed': 'Язык изменен на',
      'logged_out': 'Выход выполнен успешно',
      'phone_updated': 'Номер телефона обновлен успешно',
      'full_name_updated': 'Полное имя обновлено успешно',
      'field_updated': 'обновлено успешно',
      
      // Network
      'no_internet': 'Нет подключения к интернету',
      'check_connection': 'Пожалуйста, проверьте подключение к интернету и попробуйте снова. Вам нужно быть онлайн для отправки запросов на доставку.',
      
      // Help & Support
      'need_help': 'Нужна помощь? Свяжитесь с нашей службой поддержки:',
      'call_support': 'Позвонить в поддержку',
      'whatsapp_support': 'Поддержка WhatsApp',
      
      // Orders
      'my_orders': 'Мои заказы',
      'delivery_id': 'Доставка #',
      'from': 'От',
      'to': 'До',
      'recipient': 'Получатель',
      'no_deliveries_yet': 'Пока нет доставок',
      'create_first_delivery': 'Создайте первую доставку, чтобы начать',
      'created_date': 'Дата создания',
      'service_information': 'Информация об услуге',
      'address_information': 'Информация об адресах',
      'pickup_type': 'Тип получения',
      'delivery_type': 'Тип доставки',
      'service_type': 'Тип услуги',
      'city_delivery': 'Городская доставка',
      'inter_city_delivery': 'Междугородняя доставка',
      'easybox': 'Office',
      'address': 'Адрес',
      'sender_information': 'Информация об отправителе',
      'recipient_information': 'Информация о получателе',
      'package_information': 'Информация о посылке',
      'description': 'Описание',
      'price': 'Цена',
      'manat': 'манат',
      
      // Profile
      'phone_number': 'Номер телефона',
      'full_name': 'Полное имя',
      'delivery_service': 'Служба доставки',
      'are_you_sure_logout': 'Вы уверены, что хотите выйти?',
      'select_language': 'Выберите язык',
      
      // Navigation
      'home': 'Главная',
    },
    'tk': {
      // App
      'app_title': 'TizGo',
      'service': 'Hyzmat',
      'tassykla': 'Tassykla',
      'loading': 'Ýüklenýär...',
      
      // Service Types
      'city': 'Aşgabat',
      'inter_city': 'Welayat',
      'select_service_type': 'Hyzmat görnüşini saýlaň',
      
      // Pickup & Delivery
      'pickup_location': 'Alyş ýeri',
      'delivery_location': 'Eltip bermek ýeri',
      'select_pickup_location': 'Alyş ýerini saýlaň',
      'select_delivery_location': 'Eltip bermek ýerini saýlaň',
      'select_pickup_first': 'Ilki alyş ýerini saýlaň',
      'select': 'Saýlaň',
      'how_do_we_collect': 'Biz sizden paketi nähili alyarys?',
      'where_do_we_deliver': 'Biz paketi nirä eltip beryäris?',
      'drop_off_easybox': 'Ofisa goýuň',
      'load_parcel_locker': 'Paketiňizi ýanyňyzdaky islän sandykda goýuň',
      'pickup_from_address': 'Adresden alyň',
      'courier_collect_address': 'Kuryer paketi siziň adresiňizden alyar',
      'delivery_to_easybox': 'Ofisa eltip bermek',
      'parcel_handover_easybox': 'Paketi kuryere beriň we ýurtda islän ofisa eltip beriň',
      'delivery_to_address': 'Adrese eltip bermek',
      'courier_deliver_address': 'Kuryer paketi görkezilen adrese eltip berer',
      'continue': 'Dowam et',
      
      // Form Fields
      'sender_name': 'Iberijiň ady',
      'sender_phone': 'Iberijiň telefon belgisi',
      'recipient_name': 'Alyjynyň ady',
      'recipient_phone': 'Alyjynyň telefon belgisi',
      'package_info': 'Paket barada maglumat',
      'package_info_hint': 'Paketiňizi beýan ediň...',
      
      // Buttons
      'create_delivery': 'Eltip bermek döretmek',
      'profile': 'Profil',
      'help_support': 'Kömek we goldaw',
      'logout': 'Çykmak',
      'language': 'Dil',
      'cancel': 'Ýatyrmak',
      'ok': 'OK',
      'save': 'Ýatda saklamak',
      'edit': 'Üýtgetmek',
      'edit_field': 'Üýtgetmek',
      
      // Validation
      'please_select_pickup': 'Alyş ýerini saýlaň',
      'please_select_delivery': 'Eltip bermek ýerini saýlaň',
      'please_enter_sender_name': 'Iberijiň adyny giriziň',
      'please_enter_recipient_name': 'Alyjynyň adyny giriziň',
      'please_enter_phone': 'Telefon belgisini giriziň',
      'phone_8_digits': 'Telefon belgisi 8 san bolmaly',
      'please_enter_package_info': 'Paket barada maglumat giriziň',
      
      // Success/Error Messages
      'delivery_created': 'Eltip bermek döredildi!',
      'language_changed': 'Dil üýtgedildi',
      'logged_out': 'Çykyş amala aşyryldy',
      'phone_updated': 'Telefon belgisi täzelendi',
      'full_name_updated': 'Doly ady täzelendi',
      'field_updated': 'täzelendi',
      
      // Network
      'no_internet': 'Internet baglanyşygy ýok',
      'check_connection': 'Internet baglanyşygyny barlaň we täzeden synanyşyň. Eltip bermek soraglaryny ibermek üçin onlaýn bolmaly.',
      
      // Help & Support
      'need_help': 'Kömek gerekmi? Goldaw hyzmatymyz bilen habarlaşyň:',
      'call_support': 'Goldaw hyzmatyna jaň ediň',
      'whatsapp_support': 'WhatsApp goldaw',
      
      // Orders
      'my_orders': 'Meniň sargytlarym',
      'delivery_id': 'Eltip bermek #',
      'from': 'Kimden',
      'to': 'Kime',
      'recipient': 'Alyjy',
      'no_deliveries_yet': 'Heniz eltip bermek ýok',
      'create_first_delivery': 'Başlamak üçin ilkinji eltip bermegi dörediň',
      'created_date': 'Döredilen senesi',
      'service_information': 'Hyzmat barada maglumat',
      'address_information': 'Adres barada maglumat',
      'pickup_type': 'Alyş görnüşi',
      'delivery_type': 'Eltip bermek görnüşi',
      'service_type': 'Hyzmat görnüşi',
      'city_delivery': 'Şäher eltip bermegi',
      'inter_city_delivery': 'Şäherara eltip bermek',
      'easybox': 'Office',
      'address': 'Adres',
      'sender_information': 'Iberiji barada maglumat',
      'recipient_information': 'Alyjy barada maglumat',
      'package_information': 'Paket barada maglumat',
      'description': 'Düşündiriş',
      'price': 'Bahasy',
      'manat': 'manat',
      
      // Profile
      'phone_number': 'Telefon belgisi',
      'full_name': 'Doly ady',
      'delivery_service': 'Eltip bermek hyzmaty',
      'are_you_sure_logout': 'Çykmak isleýändigiňize ynamlymy?',
      'select_language': 'Dil saýlaň',
      
      // Navigation
      'home': 'Baş sahypa',
    },
  };
  
  // Get translation for current language
  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? _translations['en']?[key] ?? key;
  }
  
  // Get language name
  String getLanguageName(String code) {
    return _languageNames[code] ?? code;
  }
  
  // Get native language name
  String getNativeLanguageName(String code) {
    return _nativeNames[code] ?? code;
  }
  
  // Get available languages
  List<Map<String, String>> getAvailableLanguages() {
    return _languageNames.entries.map((entry) => {
      'code': entry.key,
      'name': entry.value,
      'native': _nativeNames[entry.key] ?? entry.value,
    }).toList();
  }
  
  // Change language
  Future<void> changeLanguage(String languageCode) async {
    if (_languageNames.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      await _saveLanguage(languageCode);
      notifyListeners();
    }
  }
  
  // Load saved language
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    if (savedLanguage != null && _languageNames.containsKey(savedLanguage)) {
      _currentLanguage = savedLanguage;
      notifyListeners();
    }
  }
  
  // Save language preference
  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }
}
