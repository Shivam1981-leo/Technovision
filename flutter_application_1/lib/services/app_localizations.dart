class AppLocalizations {
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिंदी (Hindi)',
    'mr': 'मराठी (Marathi)',
    'kn': 'ಕನ್ನಡ (Kannada)',
  };

  static const Map<String, String> languageShortCodes = {
    'en': 'EN',
    'hi': 'HI',
    'mr': 'MR',
    'kn': 'KN',
  };

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Bottom Navigation
      'tabSosShield': 'SOS Shield',
      'tabPeerRadar': 'Peer Radar',
      'tabCascade': 'Cascade (60s)',
      'tabAntiLuring': 'Anti-Luring',
      'tabJuryConsole': 'Jury Console',
      'auditLog': 'Audit Log',

      // Header & App Info
      'appName': 'Sangini AI',
      'appSubtitle': 'Technovision Safety Mesh Network',
      'selectLanguage': 'Select Language',

      // Context Routing
      'contextRoutingTitle': 'Context-Aware Response Routing',
      'streetMode': 'Street / Transit Mode',
      'streetModeDesc': 'Activates 200m peer radar mesh & alerts nearby verified women',
      'homeMode': 'Home / Domestic Mode',
      'homeModeDesc': 'Discreet 181 Women Helpline routing; radar broadcast SUPPRESSED for privacy',
      'activeBadge': 'ACTIVE',
      'tapToSwitch': 'Tap to switch',

      // SOS Hero
      'heroSos': 'EMERGENCY SOS',
      'holdSos': 'HOLD 1.5s OR TAP',
      'sosActive': 'SOS BROADCASTING',
      'silentModePill': 'Discreet Silent Telemetry: ON',
      'autoEscalateNotice': '60-second auto-escalation cascade to Police 112 CAD',

      // Status Banners
      'privacyShieldActive': 'Home / Domestic Privacy Shield Active',
      'privacyShieldDesc': 'Incident is routed confidentially to 181 Rapid Desk. Peer radar broadcast is suppressed to protect victim safety.',
      'streetRadarActive': 'Street Peer Radar: 200m Mesh Active',
      'realPhonesConnected': 'other phone(s) connected in real-time. Live peer mesh online.',
      'listeningOnMesh': 'Listening on mesh. Open this app on another phone to pair automatically.',
      'thisDevice': 'This Device',
      'renamePhone': 'Rename Phone',
      'changeIdentity': 'Device Mesh Identity',
      'saveAndBroadcast': 'Save & Broadcast',
      'cancel': 'Cancel',
      'metersAway': 'away',
      'online': 'ONLINE',

      // Real Device Alerts
      'incomingAlertTitle': 'INCOMING PEER DISTRESS ALERT',
      'incomingAlertDesc': 'A nearby peer has triggered a distress signal!',
      'acceptIncident': 'Accept Incident',
      'viewRadar': 'View Radar',
      'distance': 'Distance',
      'dismiss': 'Dismiss',

      // Quick Actions
      'quickTriggers': 'Stealth & AI Triggers',
      'stealthCalc': 'Stealth Calculator Disguise',
      'stealthCalcDesc': 'Working calculator with secret PIN (911=) panic trigger',
      'voiceAi': 'Voice AI Distress Detection',
      'voiceAiDesc': 'Listens for vocal panic cues ("Bachao", "Help", scream waveform)',
      'startListening': 'Activate Mic',

      // Safe Havens & Responders
      'safeHavensTitle': '24/7 Verified Safe Havens (Shivajinagar)',
      'livePeersTitle': 'Live Connected Phones (Real Multi-Device)',
      'verifiedPeersTitle': 'Nearby Verified Responders (200m Mesh)',

      // Cascade Timer
      'cascadeTitle': '60s Auto-Escalation Countdown',
      'codeBlue': 'CODE BLUE INCIDENT',
      'timeRemaining': 'Time Remaining',
      'tier1': 'Tier 1: 200m Peer Mesh & Commuters',
      'tier2': 'Tier 2: Community Volunteers & Pink Mobile Patrol',
      'tier3': 'Tier 3: Karnataka State Police 112 CAD & Emergency SMS',
      'responderEnRoute': 'Responder En-Route',
      'stopCountdown': 'ACCEPT & STOP TIMER',
      'escalatedNotice': 'Incident Auto-Escalated to Police 112 & Pink Patrol',

      // Anti-Luring Shield
      'antiLuringTitle': 'AI Anti-Luring & Fraud Shield',
      'legitimacyScore': 'AI Legitimacy Score',
      'safeToRespond': 'Safe to respond - Genuine Distress Beacon',
      'highRiskTrap': 'High risk ambush/luring pattern detected!',
      'antiLuringChecklist': 'ML Ambush Risk Signals Evaluated',

      // Calculator Disguise
      'calcExit': 'Exit Disguise',
      'calcHint': 'Tip: Enter 911= or 999= to silently trigger distress beacon',

      // Helplines
      'emergencyHelplines': 'National Emergency Numbers',
      'police112': '112 National Emergency',
      'womenHelpline181': '181 Women in Distress',
      'pinkPolice1091': '1091 Pink Women Helpline',
    },

    'hi': {
      // Bottom Navigation
      'tabSosShield': 'SOS शील्ड',
      'tabPeerRadar': 'पीयर रडार',
      'tabCascade': 'एस्केलेशन (60s)',
      'tabAntiLuring': 'सुरक्षा शील्ड',
      'tabJuryConsole': 'ज्यूरी कंसोल',
      'auditLog': 'ऑडिट लॉग',

      // Header & App Info
      'appName': 'संगिनी AI',
      'appSubtitle': 'महिला सुरक्षा एवं पीयर रिस्पांस नेटवर्क',
      'selectLanguage': 'भाषा चुनें',

      // Context Routing
      'contextRoutingTitle': 'संदर्भ-आधारित आपातकालीन रूटिंग',
      'streetMode': 'सड़क / पारगमन मोड',
      'streetModeDesc': '200m पीयर रडार सक्रिय; निकटतम सत्यापित महिलाओं को अलर्ट भेजता है',
      'homeMode': 'घर / घरेलू सुरक्षा मोड',
      'homeModeDesc': '181 महिला हेल्पलाइन पर गोपनीय रूटिंग; गोपनीयता हेतु रडार प्रसारण छिपाया गया',
      'activeBadge': 'सक्रिय',
      'tapToSwitch': 'बदलने के लिए टैप करें',

      // SOS Hero
      'heroSos': 'आपातकालीन SOS',
      'holdSos': '1.5 सेकंड दबाएं या टैप करें',
      'sosActive': 'SOS प्रसारित हो रहा है',
      'silentModePill': 'गोपनीय साइलेंट टेलीमेट्री: चालू',
      'autoEscalateNotice': '60 सेकंड में पुलिस 112 CAD पर स्वतः एस्केलेशन',

      // Status Banners
      'privacyShieldActive': 'घरेलू गोपनीयता शील्ड सक्रिय (24h Twist)',
      'privacyShieldDesc': 'घटना को 181 रैपिड डेस्क पर गोपनीय रूप से भेजा गया है। सुरक्षा हेतु पीयर रडार प्रसारण छिपा दिया गया है।',
      'streetRadarActive': 'सड़क पीयर रडार: 200m मेश सक्रिय',
      'realPhonesConnected': 'अन्य फोन लाइव जुड़े हुए हैं। मेश नेटवर्क सक्रिय है।',
      'listeningOnMesh': 'नेटवर्क पर सुन रहा है। स्वचालित रूप से जुड़ने के लिए दूसरे फोन पर यह ऐप खोलें।',
      'thisDevice': 'यह डिवाइस',
      'renamePhone': 'फोन का नाम बदलें',
      'changeIdentity': 'डिवाइस मेश पहचान',
      'saveAndBroadcast': 'सहेजें और प्रसारित करें',
      'cancel': 'रद्द करें',
      'metersAway': 'दूरी',
      'online': 'ऑनलाइन',

      // Real Device Alerts
      'incomingAlertTitle': 'निकटवर्ती संकट चेतावनी (SOS Alert)',
      'incomingAlertDesc': 'पास की एक महिला साथी ने आपातकालीन संकेत भेजा है!',
      'acceptIncident': 'घटना स्वीकार करें',
      'viewRadar': 'रडार देखें',
      'distance': 'दूरी',
      'dismiss': 'हटाएं',

      // Quick Actions
      'quickTriggers': 'गोपनीय एवं AI ट्रिगर',
      'stealthCalc': 'कैलकुलेटर भेस (Stealth Mode)',
      'stealthCalcDesc': 'गुप्त पिन (911=) के साथ चालू कैलकुलेटर जो चुपके से SOS भेजता है',
      'voiceAi': 'आवाज AI संकट पहचान',
      'voiceAiDesc': 'आपातकालीन शब्दों ("बचाओ", "Help") और तनाव तरंगों की पहचान करता है',
      'startListening': 'माइक चालू करें',

      // Safe Havens & Responders
      'safeHavensTitle': '24/7 सत्यापित सुरक्षित स्थान (शिवाजीनगर)',
      'livePeersTitle': 'लाइव कनेक्टेड फोन (रियल मल्टी-डिवाइस)',
      'verifiedPeersTitle': 'निकटतम सत्यापित महिला साथी (200m मेश)',

      // Cascade Timer
      'cascadeTitle': '60s स्वतः-एस्केलेशन उलटी गिनती',
      'codeBlue': 'कोड ब्लू आपातकाल',
      'timeRemaining': 'शेष समय',
      'tier1': 'टियर 1: 200m महिला पीयर मेश व यात्री',
      'tier2': 'टियर 2: सामुदायिक स्वयंसेवक व पिंक मोबाइल पेट्रोल',
      'tier3': 'टियर 3: राज्य पुलिस 112 CAD और आपातकालीन SMS',
      'responderEnRoute': 'सहायक रास्ते में है',
      'stopCountdown': 'स्वीकार करें और टाइमर रोकें',
      'escalatedNotice': 'घटना स्वतः पुलिस 112 और पिंक पेट्रोल को एस्केलेट हो गई है',

      // Anti-Luring Shield
      'antiLuringTitle': 'AI एंटी-ल्यूरिंग व फ्रॉड शील्ड',
      'legitimacyScore': 'AI प्रामाणिकता स्कोर',
      'safeToRespond': 'सहायता हेतु सुरक्षित - वास्तविक आपातकाल',
      'highRiskTrap': 'उच्च जोखिम वाला जाल/घात पैटर्न पहचाना गया!',
      'antiLuringChecklist': 'ML घात जोखिम सिग्नल मूल्यांकन',

      // Calculator Disguise
      'calcExit': 'भेस से बाहर निकलें',
      'calcHint': 'संकेत: चुपके से SOS भेजने के लिए 911= या 999= दर्ज करें',

      // Helplines
      'emergencyHelplines': 'राष्ट्रीय आपातकालीन नंबर',
      'police112': '112 राष्ट्रीय आपातकाल',
      'womenHelpline181': '181 महिला हेल्पलाइन',
      'pinkPolice1091': '1091 पिंक महिला हेल्पलाइन',
    },

    'mr': {
      // Bottom Navigation
      'tabSosShield': 'SOS कवच',
      'tabPeerRadar': 'पीअर रडार',
      'tabCascade': 'एस्केलेशन (60s)',
      'tabAntiLuring': 'सुरक्षा कवच',
      'tabJuryConsole': 'ज्युरी कन्सोल',
      'auditLog': 'ऑडिट लॉग',

      // Header & App Info
      'appName': 'संगिनी AI',
      'appSubtitle': 'महिला सुरक्षा आणि पीअर रिस्पॉन्स नेटवर्क',
      'selectLanguage': 'भाषा निवडा',

      // Context Routing
      'contextRoutingTitle': 'संदर्भ-आधारित आपत्कालीन मार्गक्रमण',
      'streetMode': 'रस्ता / प्रवास मोड',
      'streetModeDesc': '200m पीअर रडार मेश सक्रिय; जवळच्या पडताळणीकृत महिलांना अलर्ट पाठवतो',
      'homeMode': 'घर / घरगुती सुरक्षा मोड',
      'homeModeDesc': '181 महिला हेल्पलाइनवर गोपनीय पाठवणी; गोपनीयतेसाठी रडार प्रसारण लपवले आहे',
      'activeBadge': 'सक्रिय',
      'tapToSwitch': 'बदलण्यासाठी टॅप करा',

      // SOS Hero
      'heroSos': 'आपत्कालीन SOS',
      'holdSos': '1.5 सेकंद दाबा किंवा टॅप करा',
      'sosActive': 'SOS प्रसारित होत आहे',
      'silentModePill': 'गोपनीय सायलेंट टेलिमेट्री: चालू',
      'autoEscalateNotice': '60 सेकंदात पोलीस 112 CAD कडे स्वयंचलित एस्केलेशन',

      // Status Banners
      'privacyShieldActive': 'घरगुती गोपनीयता कवच सक्रिय (24h Twist)',
      'privacyShieldDesc': 'घटना 181 रॅपिड डेस्ककडे गोपनीयरीत्या पाठवली गेली आहे. सुरक्षिततेसाठी पीअर रडार प्रसारण लपवले आहे.',
      'streetRadarActive': 'रस्ता पीअर रडार: 200m मेश सक्रिय',
      'realPhonesConnected': 'इतर फोन थेट जोडलेले आहेत. मेश नेटवर्क सक्रिय आहे.',
      'listeningOnMesh': 'नेटवर्कवर ऐकत आहे. स्वयंचलित जोडणीसाठी दुसऱ्या फोनवर हे ॲप उघडा.',
      'thisDevice': 'हे डिव्हाइस',
      'renamePhone': 'फोनचे नाव बदला',
      'changeIdentity': 'डिव्हाइस मेश ओळख',
      'saveAndBroadcast': 'जतन करा आणि प्रसारित करा',
      'cancel': 'रद्द करा',
      'metersAway': 'अंतरावर',
      'online': 'ऑनलाइन',

      // Real Device Alerts
      'incomingAlertTitle': 'जवळच्या संकटाचा इशारा (SOS Alert)',
      'incomingAlertDesc': 'जवळच्या एका भगिनीने आपत्कालीन सिग्नल पाठवला आहे!',
      'acceptIncident': 'घटना स्वीकारा',
      'viewRadar': 'रडार पहा',
      'distance': 'अंतर',
      'dismiss': 'बंद करा',

      // Quick Actions
      'quickTriggers': 'गोपनीय आणि AI ट्रिगर्स',
      'stealthCalc': 'कॅल्क्युलेटर सोंग (Stealth Mode)',
      'stealthCalcDesc': 'गुप्त पिन (911=) सह चालू कॅल्क्युलेटर जे शांतपणे SOS पाठवते',
      'voiceAi': 'व्हॉइस AI संकट ओळख',
      'voiceAiDesc': 'आपत्कालीन शब्द ("वाचवा", "Help") आणि ताण लहरी शोधून काढते',
      'startListening': 'माईक चालू करा',

      // Safe Havens & Responders
      'safeHavensTitle': '24/7 पडताळणीकृत सुरक्षित ठिकाणे (शिवाजीनगर)',
      'livePeersTitle': 'थेट जोडलेले फोन (रिअल मल्टि-डिव्हाइस)',
      'verifiedPeersTitle': 'जवळच्या पडताळणीकृत महिला मदतनीस (200m मेश)',

      // Cascade Timer
      'cascadeTitle': '60s स्वयंचलित एस्केलेशन उलटी गिनती',
      'codeBlue': 'कोड ब्लू आपत्काळ',
      'timeRemaining': 'उर्वरित वेळ',
      'tier1': 'टियर 1: 200m महिला पीअर मेश व प्रवासी',
      'tier2': 'टियर 2: समुदाय स्वयंसेवक व पिंक मोबाईल पेट्रोल',
      'tier3': 'टियर 3: राज्य पोलीस 112 CAD आणि आपत्कालीन SMS',
      'responderEnRoute': 'मदतनीस मार्गावर आहे',
      'stopCountdown': 'स्वीकारा आणि टाइमर थांबवा',
      'escalatedNotice': 'घटना स्वयंचलितपणे पोलीस 112 आणि पिंक पेट्रोलकडे पाठवली गेली आहे',

      // Anti-Luring Shield
      'antiLuringTitle': 'AI अँटी-ल्युरिंग व फसवणूक सुरक्षा',
      'legitimacyScore': 'AI सत्यता स्कोअर',
      'safeToRespond': 'मदतीसाठी सुरक्षित - खरा आपत्काळ',
      'highRiskTrap': 'उच्च धोक्याचा सापळा/घात पॅटर्न आढळला!',
      'antiLuringChecklist': 'ML घात जोखीम सिग्नल मूल्यमापन',

      // Calculator Disguise
      'calcExit': 'सोंगातून बाहेर पडा',
      'calcHint': 'टीप: गुप्तपणे SOS पाठवण्यासाठी 911= किंवा 999= प्रविष्ट करा',

      // Helplines
      'emergencyHelplines': 'राष्ट्रीय आपत्कालीन क्रमांक',
      'police112': '112 राष्ट्रीय आपत्कालीन',
      'womenHelpline181': '181 महिला हेल्पलाइन',
      'pinkPolice1091': '1091 पिंक महिला हेल्पलाइन',
    },

    'kn': {
      // Bottom Navigation
      'tabSosShield': 'SOS ಕವಚ',
      'tabPeerRadar': 'ಪೀರ್ ರೇಡಾರ್',
      'tabCascade': 'ಎಸ್ಕಲೇಷನ್ (60s)',
      'tabAntiLuring': 'ರಕ್ಷಣಾ ಶೀಲ್ಡ್',
      'tabJuryConsole': 'ಜ್ಯೂರಿ ಕನ್ಸೋಲ್',
      'auditLog': 'ಆಡಿಟ್ ಲಾಗ್',

      // Header & App Info
      'appName': 'ಸಂಗಿನಿ AI',
      'appSubtitle': 'ಮಹಿಳಾ ಸುರಕ್ಷತೆ ಮತ್ತು ಪೀರ್ ಪ್ರತಿಕ್ರಿಯೆ ನೆಟ್‌ವರ್ಕ್',
      'selectLanguage': 'ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ',

      // Context Routing
      'contextRoutingTitle': 'ಸನ್ನಿವೇಶ ಆಧಾರಿತ ತುರ್ತು ರೂಟಿಂಗ್',
      'streetMode': 'ರಸ್ತೆ / ಸಂಚಾರ ಮೋಡ್',
      'streetModeDesc': '200m ಪೀರ್ ರೇಡಾರ್ ಮೆಶ್ ಸಕ್ರಿಯ; ಹತ್ತಿರದ ಪರಿಶೀಲಿತ ಮಹಿಳೆಯರಿಗೆ ಎಚ್ಚರಿಕೆ ರವಾನೆ',
      'homeMode': 'ಮನೆ / ಕೌಟುಂಬಿಕ ರಕ್ಷಣಾ ಮೋಡ್',
      'homeModeDesc': '181 ಮಹಿಳಾ ಸಹಾಯವಾಣಿಗೆ ರಹಸ್ಯ ರೂಟಿಂಗ್; ಗೌಪ್ಯತೆಗಾಗಿ ರೇಡಾರ್ ಪ್ರಸಾರ ಮರೆಮಾಡಲಾಗಿದೆ',
      'activeBadge': 'ಸಕ್ರಿಯ',
      'tapToSwitch': 'ಬದಲಾಯಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ',

      // SOS Hero
      'heroSos': 'ತುರ್ತು SOS',
      'holdSos': '1.5 ಸೆಕೆಂಡು ಒತ್ತಿಹಿಡಿಯಿರಿ ಅಥವಾ ಟ್ಯಾಪ್ ಮಾಡಿ',
      'sosActive': 'SOS ಪ್ರಸಾರವಾಗುತ್ತಿದೆ',
      'silentModePill': 'ರಹಸ್ಯ ಸೈಲೆಂಟ್ ಟೆಲಿಮೆಟ್ರಿ: ಆನ್',
      'autoEscalateNotice': '60 ಸೆಕೆಂಡುಗಳಲ್ಲಿ ಪೊಲೀಸ್ 112 CAD ಗೆ ಸ್ವಯಂ ಎಸ್ಕಲೇಶನ್',

      // Status Banners
      'privacyShieldActive': 'ಮನೆ ಗೌಪ್ಯತೆ ಕವಚ ಸಕ್ರಿಯ (24h Twist)',
      'privacyShieldDesc': 'ಘಟನೆಯನ್ನು 181 ರ್ಯಾಪಿಡ್ ಡೆಸ್ಕ್‌ಗೆ ರಹಸ್ಯವಾಗಿ ಕಳುಹಿಸಲಾಗಿದೆ. ಸುರಕ್ಷತೆಗಾಗಿ ಪೀರ್ ರೇಡಾರ್ ಪ್ರಸಾರ ಮರೆಮಾಡಲಾಗಿದೆ.',
      'streetRadarActive': 'ರಸ್ತೆ ಪೀರ್ ರೇಡಾರ್: 200m ಮೆಶ್ ಸಕ್ರಿಯ',
      'realPhonesConnected': 'ಇತರ ಫೋನ್‌ಗಳು ಲೈವ್ ಸಂಪರ್ಕದಲ್ಲಿವೆ. ಮೆಶ್ ನೆಟ್‌ವರ್ಕ್ ಸಕ್ರಿಯವಾಗಿದೆ.',
      'listeningOnMesh': 'ನೆಟ್‌ವರ್ಕ್‌ನಲ್ಲಿ ಆಲಿಸುತ್ತಿದೆ. ಸ್ವಯಂಚಾಲಿತ ಜೋಡಣೆಗಾಗಿ ಇನ್ನೊಂದು ಫೋನ್‌ನಲ್ಲಿ ಈ ಆಪ್ ತೆರೆಯಿರಿ.',
      'thisDevice': 'ಈ ಸಾಧನ',
      'renamePhone': 'ಫೋನ್ ಹೆಸರು ಬದಲಾಯಿಸಿ',
      'changeIdentity': 'ಸಾಧನ ಮೆಶ್ ಗುರುತು',
      'saveAndBroadcast': 'ಉಳಿಸಿ ಮತ್ತು ಪ್ರಸಾರ ಮಾಡಿ',
      'cancel': 'ರದ್ದುಮಾಡಿ',
      'metersAway': 'ದೂರದಲ್ಲಿ',
      'online': 'ಆನ್‌ಲೈನ್',

      // Real Device Alerts
      'incomingAlertTitle': 'ಹತ್ತಿರದ ತುರ್ತು ಎಚ್ಚರಿಕೆ (SOS Alert)',
      'incomingAlertDesc': 'ಹತ್ತಿರದ ಮಹಿಳಾ ಒಡನಾಡಿ ತುರ್ತು ಸಂಕೇತ ಕಳುಹಿಸಿದ್ದಾರೆ!',
      'acceptIncident': 'ಘಟನೆ ಸ್ವೀಕರಿಸಿ',
      'viewRadar': 'ರೇಡಾರ್ ವೀಕ್ಷಿಸಿ',
      'distance': 'ದೂರ',
      'dismiss': 'ವಜಾಗೊಳಿಸಿ',

      // Quick Actions
      'quickTriggers': 'ರಹಸ್ಯ ಮತ್ತು AI ಪ್ರಚೋದಕಗಳು',
      'stealthCalc': 'ಕ್ಯಾಲ್ಕುಲೇಟರ್ ವೇಷ (Stealth Mode)',
      'stealthCalcDesc': 'ರಹಸ್ಯ ಪಿನ್ (911=) ನೊಂದಿಗೆ ಚಾಲ್ತಿಯಲ್ಲಿರುವ ಕ್ಯಾಲ್ಕುಲೇಟರ್ ರಹಸ್ಯವಾಗಿ SOS ಕಳುಹಿಸುತ್ತದೆ',
      'voiceAi': 'ಧ್ವನಿ AI ತುರ್ತು ಪತ್ತೆ',
      'voiceAiDesc': 'ತುರ್ತು ಧ್ವನಿಗಳು ("ಕಾಪಾಡಿ", "Help") ಮತ್ತು ಆತಂಕದ ತರಂಗಗಳನ್ನು ಪತ್ತೆ ಮಾಡುತ್ತದೆ',
      'startListening': 'ಮೈಕ್ ಆನ್ ಮಾಡಿ',

      // Safe Havens & Responders
      'safeHavensTitle': '24/7 ಪರಿಶೀಲಿತ ಸುರಕ್ಷಿತ ಸ್ಥಳಗಳು (ಶಿವಾಜಿನಗರ)',
      'livePeersTitle': 'ಲೈವ್ ಸಂಪರ್ಕಿತ ಫೋನ್‌ಗಳು (ರಿಯಲ್ ಮಲ್ಟಿ-ಸಾಧನ)',
      'verifiedPeersTitle': 'ಹತ್ತಿರದ ಪರಿಶೀಲಿತ ಮಹಿಳಾ ಪ್ರತಿಸ್ಪಂದಕರು (200m ಮೆಶ್)',

      // Cascade Timer
      'cascadeTitle': '60s ಸ್ವಯಂ-ಎಸ್ಕಲೇಶನ್ ಕೌಂಟ್‌ಡೌನ್',
      'codeBlue': 'ಕೋಡ್ ಬ್ಲೂ ತುರ್ತು ಪರಿಸ್ಥಿತಿ',
      'timeRemaining': 'ಉಳಿದಿರುವ ಸಮಯ',
      'tier1': 'ಟೈರ್ 1: 200m ಮಹಿಳಾ ಪೀರ್ ಮೆಶ್ ಮತ್ತು ಪ್ರಯಾಣಿಕರು',
      'tier2': 'ಟೈರ್ 2: ಸಮುದಾಯ ಸ್ವಯಂಸೇವಕರು ಮತ್ತು ಪಿಂಕ್ ಮೊಬೈಲ್ ಗಸ್ತು',
      'tier3': 'ಟೈರ್ 3: ಕರ್ನಾಟಕ ರಾಜ್ಯ ಪೊಲೀಸ್ 112 CAD ಮತ್ತು ತುರ್ತು SMS',
      'responderEnRoute': 'ಪ್ರತಿಸ್ಪಂದಕರು ದಾರಿಯಲ್ಲಿದ್ದಾರೆ',
      'stopCountdown': 'ಸ್ವೀಕರಿಸಿ ಮತ್ತು ಟೈಮರ್ ನಿಲ್ಲಿಸಿ',
      'escalatedNotice': 'ಘಟನೆಯು ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಪೊಲೀಸ್ 112 ಮತ್ತು ಪಿಂಕ್ ಗಸ್ತಿಗೆ ರವಾನೆಯಾಗಿದೆ',

      // Anti-Luring Shield
      'antiLuringTitle': 'AI ವಿರೋಧಿ ಆಮಿಷ ಮತ್ತು ವಂಚನೆ ರಕ್ಷಣೆ',
      'legitimacyScore': 'AI ದೃಢೀಕರಣ ಸ್ಕೋರ್',
      'safeToRespond': 'ಸಹಾಯ ಮಾಡಲು ಸುರಕ್ಷಿತ - ನೈಜ ತುರ್ತುಸ್ಥಿತಿ',
      'highRiskTrap': 'ಹೆಚ್ಚಿನ ಅಪಾಯದ ಹೊಂಚು/ಬಲೆಯ ಮಾದರಿ ಪತ್ತೆಯಾಗಿದೆ!',
      'antiLuringChecklist': 'ML ಹೊಂಚು ಅಪಾಯದ ಸಂಕೇತಗಳ ಮೌಲ್ಯಮಾಪನ',

      // Calculator Disguise
      'calcExit': 'ವೇಷದಿಂದ ಹೊರಬನ್ನಿ',
      'calcHint': 'ಸಲಹೆ: ರಹಸ್ಯವಾಗಿ SOS ಕಳುಹಿಸಲು 911= ಅಥವಾ 999= ನಮೂದಿಸಿ',

      // Helplines
      'emergencyHelplines': 'ರಾಷ್ಟ್ರೀಯ ತುರ್ತು ಸಂಖ್ಯೆಗಳು',
      'police112': '112 ರಾಷ್ಟ್ರೀಯ ತುರ್ತು',
      'womenHelpline181': '181 ಮಹಿಳಾ ಸಹಾಯವಾಣಿ',
      'pinkPolice1091': '1091 ಪಿಂಕ್ ಮಹಿಳಾ ಸಹಾಯವಾಣಿ',
    },
  };

  static String get(String key, [String languageCode = 'en']) {
    final langMap = _localizedValues[languageCode] ?? _localizedValues['en']!;
    return langMap[key] ?? _localizedValues['en']?[key] ?? key;
  }
}
