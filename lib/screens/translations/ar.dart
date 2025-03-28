import '../../models/user.dart';

final Map<String, String> ar = {
  // Général de l'application
  'titre_app': 'تطبيقي',
  'chargement': 'جاري التحميل...',
  'erreur': 'خطأ',
  'succes': 'نجاح',
  'annuler': 'إلغاء',
  'enregistrer': 'حفظ',
  'supprimer': 'حذف',
  'modifier': 'تعديل',
  'confirmer': 'تأكيد',
  'retour': 'رجوع',
  'suivant': 'التالي',
  'rechercher': 'بحث',
  'envoyer': 'إرسال',
  'fermer': 'إغلاق',
  'oui': 'نعم',
  'non': 'لا',

  // Navigation
  'accueil': 'الرئيسية',
  'profil': 'الملف الشخصي',
  'messages': 'الرسائل',
  'notifications': 'الإشعارات',
  'parametres': 'الإعدادات',
  'tableau_de_bord': 'لوحة التحكم',
  'statistiques': 'الإحصائيات',
  'portfolio': 'المحفظة',

  // Authentification
  'connexion': 'تسجيل الدخول',
  'inscription': 'إنشاء حساب',
  'deconnexion': 'تسجيل الخروج',
  'email': 'البريد الإلكتروني',
  'mot_de_passe': 'كلمة المرور',
  'confirmer_mot_de_passe': 'تأكيد كلمة المرور',
  'mot_de_passe_oublie': 'نسيت كلمة المرور؟',
  'reinitialiser_mot_de_passe': 'إعادة تعيين كلمة المرور',
  'nom_utilisateur': 'اسم المستخدم',
  'se_souvenir_de_moi': 'تذكرني',
  'connexion_reussie': 'تم تسجيل الدخول بنجاح',
  'connexion_echouee': 'فشل تسجيل الدخول',
  'inscription_reussie': 'تم إنشاء الحساب بنجاح',
  'inscription_echouee': 'فشل إنشاء الحساب',

  // Profil
  'modifier_profil': 'تعديل الملف الشخصي',
  'nom': 'الاسم',
  'prenom': 'الاسم الأول',
  'nom_famille': 'اسم العائلة',
  'telephone': 'رقم الهاتف',
  'adresse': 'العنوان',
  'biographie': 'نبذة شخصية',
  'date_naissance': 'تاريخ الميلاد',
  'genre': 'الجنس',
  'homme': 'ذكر',
  'femme': 'أنثى',
  'autre': 'آخر',
  'profil_mis_a_jour': 'تم تحديث الملف الشخصي',
  'changer_photo': 'تغيير الصورة',
  'telecharger_photo': 'رفع صورة',

  // Messages
  'nouveau_message': 'رسالة جديدة',
  'envoyer_message': 'إرسال رسالة',
  'message': 'رسالة',
  'discussions': 'المحادثات',
  'taper_message': 'اكتب رسالة...',
  'aucun_message': 'لا توجد رسائل',
  'en_ligne': 'متصل',
  'hors_ligne': 'غير متصل',
  'derniere_connexion': 'آخر ظهور',
  'en_train_ecrire': 'يكتب...',

  // Notifications
  'parametres_notification': 'إعدادات الإشعارات',
  'notifications_push': 'إشعارات الدفع',
  'notifications_email': 'إشعارات البريد الإلكتروني',
  'notifications_sms': 'إشعارات الرسائل القصيرة',
  'toutes_notifications': 'جميع الإشعارات',
  'aucune_notification': 'لا توجد إشعارات',
  'marquer_tout_lu': 'تعيين الكل كمقروء',

  // Sécurité et confidentialité
  'securite_confidentialite': 'الأمان والخصوصية',
  'changer_mot_de_passe': 'تغيير كلمة المرور',
  'mot_de_passe_actuel': 'كلمة المرور الحالية',
  'nouveau_mot_de_passe': 'كلمة المرور الجديدة',
  'appareils_connectes': 'الأجهزة المتصلة',
  'historique_connexion': 'سجل تسجيل الدخول',
  'authentification_deux_facteurs': 'المصادقة الثنائية',
  'parametres_confidentialite': 'إعدادات الخصوصية',
  'qui_peut_voir_profil': 'من يمكنه رؤية ملفي الشخصي',
  'qui_peut_me_contacter': 'من يمكنه التواصل معي',
  'tout_le_monde': 'الجميع',
  'amis_seulement': 'الأصدقاء فقط',
  'personne': 'لا أحد',

  // Abonnement
  'abonnement': 'الاشتراك',
  'plan_abonnement': 'خطة الاشتراك',
  'gratuit': 'مجاني',
  'premium': 'مميز',
  'business': 'أعمال',
  'mettre_a_niveau': 'ترقية',
  'retrograder': 'تخفيض',
  'plan_actuel': 'الخطة الحالية',
  'facturation': 'الفواتير',
  'methode_paiement': 'طريقة الدفع',
  'details_abonnement': 'تفاصيل الاشتراك',
  'expire_le': 'ينتهي في',

  // FAQ et Aide
  'faq': 'الأسئلة الشائعة',
  'aide': 'مساعدة',
  'contacter_support': 'التواصل مع الدعم',
  'contenu_aide': 'هل تحتاج إلى مساعدة في إعدادات اللغة؟ اتصل بالدعم الفني على 0540274628',
  'questions_frequentes': 'الأسئلة المتكررة',
  'comment_utiliser': 'كيفية الاستخدام',
  'depannage': 'استكشاف الأخطاء وإصلاحها',

  // Langue
  'langue': 'اللغة',
  'selectionner_langue': 'اختر لغتك المفضلة',
  'langue_modifiee': 'تم تغيير اللغة',

  // Portfolio
  'portfolio': 'المحفظة',
  'modifier_portfolio': 'تعديل المحفظة',
  'ajouter_projet': 'إضافة مشروع',
  'titre_projet': 'عنوان المشروع',
  'description_projet': 'وصف المشروع',
  'url_projet': 'رابط المشروع',
  'image_projet': 'صورة المشروع',
  'competences': 'المهارات',
  'ajouter_competence': 'إضافة مهارة',
  'experience': 'الخبرة',
  'education': 'التعليم',
'aide_portfolio': 'محتوى المساعدة للمحفظة',
'clients': 'العملاء',
'evaluation': 'التقييم',
'cv': 'السيرة الذاتية',
'a propos de moi': 'نبذة عني',
'projets_recents': 'المشاريع الحديثة',
'contact': 'التواصل',
  // Contrats
  'contrat': 'العقد',
  'contrats': 'العقود',
  'nouveau_contrat': 'عقد جديد',
  'details_contrat': 'تفاصيل العقد',
  'date_debut': 'تاريخ البدء',
  'date_fin': 'تاريخ الانتهاء',
  'valeur_contrat': 'قيمة العقد',
  'statut_contrat': 'حالة العقد',
  'actif': 'نشط',
  'termine': 'مكتمل',
  'annule': 'ملغي',
  'en_attente': 'قيد الانتظار',

  // Entreprise
  'entreprise': 'المؤسسة',
  'nom_entreprise': 'اسم الشركة',
  'details_entreprise': 'تفاصيل الشركة',
  'taille_entreprise': 'حجم الشركة',
  'secteur': 'الصناعة',
  'emplacement': 'الموقع',
  'site_web': 'الموقع الإلكتروني',

  // Tableau de bord
  'tableau_bord': 'لوحة التحكم',
  'apercu': 'نظرة عامة',
  'activite_recente': 'النشاط الأخير',
  'performance': 'الأداء',
  'revenus': 'الإيرادات',
  'utilisateurs': 'المستخدمين',
  'projets': 'المشاريع',
  'taches': 'المهام',

  // Statistiques
  'statistiques': 'الإحصائيات',
  'analytique': 'التحليلات',
  'rapports': 'التقارير',
  'quotidien': 'يومي',
  'hebdomadaire': 'أسبوعي',
  'mensuel': 'شهري',
  'annuel': 'سنوي',
  'total': 'المجموع',
  'moyenne': 'المتوسط',
  'graphique': 'الرسم البياني',
  'donnees': 'البيانات',

  // Temps et Date
  'aujourd_hui': 'اليوم',
  'hier': 'أمس',
  'demain': 'غدا',
  'jour': 'يوم',
  'semaine': 'أسبوع',
  'mois': 'شهر',
  'annee': 'سنة',
  'date': 'تاريخ',
  'heure': 'وقت',

  // Erreurs et Validations
  'champ_requis': 'هذا الحقل مطلوب',
  'email_invalide': 'بريد إلكتروني غير صالح',
  'mot_de_passe_trop_court': 'كلمة المرور قصيرة جدا',
  'mots_de_passe_different': 'كلمات المرور غير متطابقة',
  'erreur_survenue': 'حدث خطأ ما',
  'reessayer': 'حاول مرة أخرى',
  'erreur_connexion': 'خطأ في الاتصال',
  'non_trouve': 'غير موجود',

  // Divers
  'bienvenue': 'مرحبا',
  'bon_retour': 'مرحبا بعودتك',
  'commencer': 'ابدأ الآن',
  'en_savoir_plus': 'تعلم المزيد',
  'voir_tout': 'عرض الكل',
  'afficher_plus': 'عرض المزيد',
  'afficher_moins': 'عرض أقل',
  'lire_plus': 'قراءة المزيد',
  'continuer': 'متابعة',
  'partager': 'مشاركة',
  'j_aime': 'إعجاب',
  'commenter': 'تعليق',
  'suivre': 'متابعة',
  'ne_plus_suivre': 'إلغاء المتابعة',
  'Paramètres': 'الإعدادات',
  'Aide': 'مساعدة',
  'Fermer': 'إغلاق',
  'Compte': 'حساب',
  'Modifier le profil': 'تعديل الملف الشخصي',
  'Notifications': 'الإشعارات',
  'Confidentialité': 'خصوصية',
  'Tableau de bord': 'لوحة التحكم',
  'Statistiques': 'الإحصائيات',
  'Abonnement': 'الاشتراك',
  'Langue': 'اللغة',
  'Centre d\'aide': 'مساعدة',
  'À propos': 'نبذة عني',
  'Déconnexion': 'تسجيل الخروج',
  'Contrats': 'العقود',
  'Plan Premium': 'مميز',
  'ACTIF': 'نشط',
  'Mode clair': 'وضع فاتح',
  'Thème': 'السمة',
  'FAQ et guides': 'الأسئلة الشائعة',
  'Version': 'الإصدار',
  'Modifier le compte': 'تعديل الحساب',
'Modifiez vos informations personnelles' : 'عدّل معلوماتك الشخصية',
'Modifier votre compte public et portefolio': 'تعديل حسابك العام والمحفظة',
'Vue globale des offres d emplois': 'نظرة عامة على عروض العمل',
'Gérez vos préférences de notification': 'إدارة تفضيلات الإشعارات',
'Gérez la sécurité de votre compte': 'إدارة أمان حسابك',
'Gérez vos contrats': 'إدارة العقود الخاصة بك',
'Consultez vos statistiques d\'utilisation': 'عرض إحصائيات الاستخدام الخاصة بك',
'Gérez votre abonnement': 'إدارة اشتراكك',
'Français': 'الفرنسية',
'Mode clair': 'وضع فاتح',
'FAQ et guides': 'الأسئلة الشائعة والأدلة',
'Version 1.0.0': 'الإصدار 1.0.0',
'Préférences': 'التفضيلات',
'Support': 'الدعم',
'Besoin d\'aide avec les paramètres ? Contactez notre support technique au 0549819905': 'بحاجة إلى مساعدة مع الإعدادات؟ اتصل بدعمنا الفني على 0549819905',
'Erreur de chargement': 'خطأ في التحميل',

"Bonjour, @name 👋": "مرحبًا، @name 👋",
'Vos données sont en sécurité' : 'بياناتك آمنة',
'Statut de Protection': 'حالة الحماية',
'Toutes vos données sont protégées': 'جميع بياناتك محمية',
'Actions Rapides': 'إجراءات سريعة',
'Nouveau\nContrat': 'عقد\nجديد',
'Vérifier\nStatut': 'التحقق من\nالحالة',
'Scanner\nMenaces': 'فحص\nالتهديدات',
'Contrats Actifs': 'العقود النشطة',
'Tech Solutions Inc.': 'شركة تك سوليوشنز',
'En cours': 'قيد التنفيذ',
'15 Feb 2025': '15 فبراير 2025',
'45,000 DA': '45,000 دج',
'Digital Agency SARL': 'وكالة ديجيتال ش.ذ.م.م',
'En attente': 'قيد الانتظار',
'20 Feb 2025': '20 فبراير 2025',
'30,000 DA': '30,000 دج',
'Conseil du Jour': 'نصيحة اليوم',
'Activez l\'authentification à deux facteurs pour une sécurité renforcée de votre compte.': 'قم بتفعيل المصادقة الثنائية لتعزيز أمان حسابك.',
'Activer maintenant': 'تفعيل الآن',
'Gérez la sécurité de votre compte': 'إدارة أمان حسابك',
'Gérez vos contrats': 'إدارة العقود الخاصة بك',
'Consultez vos statistiques d\'utilisation': 'عرض إحصائيات الاستخدام الخاصة بك',
'Gérez votre abonnement': 'إدارة اشتراكك',
'Français': 'الفرنسية',
'Mode clair': 'وضع فاتح',
'FAQ et guides': 'الأسئلة الشائعة والأدلة',
'Version 1.0.0': 'الإصدار 1.0.0',
'Préférences': 'التفضيلات',
'Support': 'الدعم',
'Besoin d\'aide avec les paramètres ? Contactez notre support technique au 0549819905': 'بحاجة إلى مساعدة مع الإعدادات؟ اتصل بدعمنا الفني على 0549819905',
'Erreur de chargement': 'خطأ في التحميل',
'Tous': 'الكل',
'Développement Web': 'تطوير الويب',
'Design UI/UX': 'تصميم واجهة المستخدم/تجربة المستخدم',
'Marketing Digital': 'التسويق الرقمي',
'Mobile': 'الجوال',
'2': '٢',
'Rechercher un profil...': 'البحث عن ملف شخصي...',
'Suggestions populaires:': 'الاقتراحات الشائعة:',
'React Developer': 'مطور رياكت',
'UI Designer': 'مصمم واجهة المستخدم',
'Full Stack': 'فول ستاك',
'Entreprises': 'الشركات',
'Freelancers': 'المستقلون',
'Recherche: Développeur Web Frontend': 'مطلوب: مطور واجهة أمامية للويب',
'React': 'رياكت',
'3 ans exp.': '٣ سنوات خبرة',
'Contacter': 'تواصل',
'Développeur Web Full Stack': 'مطور ويب فول ستاك',
' 4.8 (156 avis)': ' ٤.٨ (١٥٦ تقييم)',
'Node.js': 'نود.جي إس',
'Voir plus': 'عرض المزيد',
  'Aide': 'مساعدة',
  'Besoin d\'aide ? Contactez notre support technique au 0540274628': 'هل تحتاج إلى مساعدة؟ اتصل بدعمنا الفني على الرقم 0540274628',
  'Fermer': 'إغلاق',
  'Nous sommes là pour vous aider avec tout sur l\'application Ahmini': 'نحن هنا لمساعدتك في كل ما يتعلق بتطبيق أهmini',
  'Consultez nos questions fréquemment posées ou envoyez-nous un email..': 'تصفح الأسئلة الشائعة أو أرسل لنا بريدًا إلكترونيًا..',
  'FAQ': 'الأسئلة الشائعة',
  'Qu\'est-ce que Ahmini ?': 'ما هو أهmini؟',
  'Ahmini est une application qui permet aux freelances de trouver des entreprises pour offrir leurs services, et permet aux entreprises de trouver des freelances capables de répondre à leurs besoins, tout en sécurisant les transactions grâce à un contrat signé par les deux parties.': 'أهmini هو تطبيق يسمح للعاملين لحسابهم الخاص بالعثور على شركات لتقديم خدماتهم، ويسمح للشركات بالعثور على عاملين مستقلين قادرين على تلبية احتياجاتهم، مع تأمين المعاملات من خلال عقد موقع من الطرفين.',
  'Comment procéder au paiement ?': 'كيف يمكن إجراء الدفع؟','Comment être sûr que l\'entreprise me paiera ?': 'كيف يمكنني التأكد من أن الشركة ستدفع لي؟',
  'Grâce à un contrat signé par l\'entreprise et le freelance.': 'من خلال عقد موقع من قبل الشركة والفريلانسر.',
  'Comment être sûr que le freelance accomplira le travail demandé ?': 'كيف يمكنني التأكد من أن الفريلانسر سينجز العمل المطلوب؟',
  'Grâce à un contrat signé par l\'entreprise et le freelance.': 'من خلال عقد موقع من قبل الشركة والفريلانسر.',
  'Comment puis-je demander au freelance le prix du service ?': 'كيف يمكنني طلب سعر الخدمة من الفريلانسر؟',
  'En expliquant le travail demandé à ce freelance via le chat, et il pourra proposer un prix.': 'عن طريق شرح العمل المطلوب لهذا الفريلانسر عبر الدردشة، وسيتمكن من اقتراح سعر.',
  'Toujours bloqué ? Nous sommes à un mail près': 'ما زلت عالقًا؟ نحن على بعد بريد إلكتروني واحد فقط',
  'Envoyer un message': 'إرسال رسالة',
};



