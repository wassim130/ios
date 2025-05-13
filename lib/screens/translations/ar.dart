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
  'Modifier les coordonnées de votre entreprise': 'تعديل معلومات الشركة',
  'Modifier votre compte public et portefolio': 'تعديل الحساب العام والمحفظة',
  'Personnalisez votre profil'  : 'تخصيص ملفك الشخصي',
  'Profil complété à 80%': 'تم إكمال الملف الشخصي بنسبة 80%',
  'Modifier votre profil' : 'تعديل ملفك الشخصي',


  // Compte
  'Créez votre entreprise': 'أنشئ شركتك',
  'Bienvenue sur votre entreprise': 'مرحبًا بك في شركتك',
  'Créez votre entreprise professionnel pour vous démarquer auprès des clients potentiels.': 'أنشئ شركتك المهنية لتميز نفسك أمام العملاء المحتملين.',
  'Informations personnelles': 'المعلومات الشخصية',
  'Ajoutez vos informations de base pour que les clients puissent vous connaître.': 'أضف معلوماتك الأساسية ليتمكن العملاء من التعرف عليك.',
  'Expérience professionnelle': 'الخبرة المهنية',
  'Partagez votre parcours et vos compétences pour attirer les bons projets.': 'شارك مسيرتك ومهاراتك لجذب المشاريع المناسبة.',
  'Coordonnées': 'معلومات الاتصال',
  'Ajoutez vos coordonnées pour que les clients puissent vous contacter facilement.': 'أضف معلومات الاتصال الخاصة بك ليتمكن العملاء من التواصل معك بسهولة.',
  'Projets': 'المشاريع',
  'Ajoutez vos projets pour montrer votre expertise et votre expérience.': 'أضف مشاريعك لعرض خبرتك وتجربتك.',
  'Votre portfolio est votre vitrine professionnelle. Commencez par ajouter une photo professionnelle et votre nom complet pour vous présenter aux clients potentiels.': 'ملفك الشخصي هو واجهتك المهنية. ابدأ بإضافة صورة احترافية واسمك الكامل لتقديم نفسك للعملاء المحتملين.',
  'Votre résumé personnel est souvent la première chose que les clients lisent. Soyez concis et mettez en avant vos points forts.': 'ملخصك الشخصي هو غالبًا أول ما يقرأه العملاء. كن موجزًا وابرز نقاط قوتك.',
  'Détaillez votre expérience professionnelle en mettant l\'accent sur les compétences pertinentes pour les projets que vous souhaitez obtenir. Un CV bien structuré augmente vos chances d\'être sélectionné.': 'فصّل خبرتك المهنية مع التركيز على المهارات المرتبطة بالمشاريع التي ترغب في الحصول عليها. سيرة ذاتية منظمة جيدًا تزيد من فرص اختيارك.',
  'Assurez-vous que vos coordonnées sont à jour pour que les clients puissent vous contacter facilement. L\'email de contact sera visible publiquement, alors utilisez une adresse professionnelle.': 'تأكد من أن معلومات الاتصال الخاصة بك محدثة لكي يتمكن العملاء من التواصل معك بسهولة. سيكون بريدك الإلكتروني مرئيًا للعموم، لذا استخدم عنوانًا مهنيًا.',
  'Ajoutez vos meilleurs projets pour montrer votre expertise. Incluez une description claire et les technologies utilisées. Des images de qualité augmenteront l\'attractivité de votre portfolio.': 'أضف أفضل مشاريعك لعرض خبرتك. قم بإدراج وصف واضح والتقنيات المستخدمة. ستزيد الصور ذات الجودة العالية من جاذبية ملفك الشخصي.',
  'Conseils': 'نصائح',
  'À propos de vous': 'عن نفسك',
  'Expérience professionnelle': 'الخبرة المهنية',
  'Télécharger votre CV': 'تحميل سيرتك الذاتية',
  'Formats acceptés: PDF, DOC, DOCX': 'الصيغ المقبولة: PDF، DOC، DOCX',
  'Coordonnées': 'معلومات الاتصال',
  'Ajouter': 'إضافة',
  'Projets': 'المشاريع',
  'Aucun projet pour le moment': 'لا توجد مشاريع في الوقت الحالي',
  'Ajoutez vos projets pour montrer votre expertise': 'أضف مشاريعك لعرض خبرتك',

  // Dashboard
  'Gérez vos offres d\'emploi et les candidatures reçues': 'إدارة الوظائف المقدمة والمقبولة',
  'Modifier Portefeuille': 'تعديل المحفظة',
  'Offres':'الوظائف',
  'Candidats': 'المرشحين',
  'Pending': 'قيد الانتظار',
  'Offres d\'emploi': 'عروض العمل',
  'Votre Portefeuille Professionnel': 'ملفك الشخصي المهني',
  'Besoin d\'aide avec votre portefeuille? Contactez notre support technique au 0549819905':'هل تحتاج مساعدة في ملفك الشخصي؟ اتصل بفريق الدعم الفني على 0549819905',
  



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
  'Gérez les notifications': 'إدارة الإشعارات',
  'Tous les messages': 'كل الرسائل',
  'Contrat': 'العقود',
  'Choisissez quelles notifications vous souhaitez recevoir..': 'اختر الإشعارات التي ترغب في تلقيها',

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
  'Points à améliorer': 'نقاط لتحسينها',
  'Actions de sécurité': 'إجراءات الأمان',
  'Paramètres de confidentialité': 'إعدادات الخصوصية',
  'Mode privé': 'الوضع الخاص',
  'Notifications de sécurité': 'الإشعارات الأمنية',
  'Recevoir une alerte lors d\'une nouvelle connexion': 'الحصول على تنبيه عند تسجيل دخول جديد',
  'Masquer votre statut en ligne': 'إخفاء حالتك على الإنترنت',
  'Conseil de sécurité': 'نصيحة للأمان',
  'Utilisez un gestionnaire de mots de passe pour créer et stocker des mots de passe forts et uniques pour chacun de vos comptes.': 'استخدم مدير كلمات المرور لإنشاء وتخزين كلمات مرور قوية ومميزة لكل حساب.',
'Changer le mot de passe': 'تغيير كلمة المرور',
'Authentification à deux facteurs': 'المصادقة الثنائية',
'Authentification à deux facteurs désactivée': 'المصادقة الثنائية غير مشغلة',
'Activée': 'مفعلة',
'Non activée': 'غير مفعلة',
'Vérification des appareils connectés': 'التحقق من الأجهزة المتصلة',
'Historique des connexions': 'سجل تسجيل الدخول',
'Paramètres de confidentialité': 'إعدادات الخصوصية',
'Notifications de connexion': 'إشعارات تسجيل الدخول',
'Recevoir une alerte lors d\'une nouvelle connexion': 'تلقي تنبيه عند تسجيل دخول جديد',
'mise a jour de mode prive avec success': 'تم تحديث الوضع الخاص بنجاح',
"Erreur dans la modification de status": "حدث خطأ أثناء تعديل الحالة",
'Sécurité & Confidentialité': 'الأمان والخصوصية',
"Pas de risque": "لا يوجد خطر",
'Moyen': 'متوسط',
"Élevé": "مرتفع",
'Changer': 'تغيير',



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
  'Aucun abonnement': 'لا يوجد اشتراك',
  'Gérez vos abonnements': 'إدارة اشتراكاتك',
  "Choisissez votre plan d'abonnement mensuel pour accéder à toutes les fonctionnalités.": "اختر خطة الاشتراك الشهرية للوصول إلى جميع الميزات.",
"Forfaits disponibles": "الباقات المتاحة",
"Finalisation de votre abonnement...": "جارٍ إتمام اشتراكك...",
"Erreur: ID de paiement manquant": "خطأ: معرف الدفع مفقود",


  // FAQ et Aide
  'faq': 'الأسئلة الشائعة',
  'aide': 'مساعدة',
  'contacter_support': 'التواصل مع الدعم',
  'contenu_aide': 'هل تحتاج إلى مساعدة في إعدادات اللغة؟ اتصل بالدعم الفني على 0540274628',
  'questions_frequentes': 'الأسئلة المتكررة',
  'comment_utiliser': 'كيفية الاستخدام',
  'depannage': 'استكشاف الأخطاء وإصلاحها',
  'assistance': 'مساعدة',

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
  'Tous les contrats': 'كل العقود',

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
  'Vue d\'ensemble':'نظرة عامة',
  'Statistiques de votre compte': 'إحصائيات حسابك',
  'Distribution des Contrats': 'توزيع العقود',
  'Score de Sécurité': 'مؤشر الأمان',
  'Activités Récentes': 'الأنشطة الأخيرة',

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

  // Theme 
  'Thème': 'المظهر',
  'clair': 'فاتح',
  'sombre': 'داكن',
  'Mode sombre': 'الوضع الداكن',
  'Mode clair': 'الوضع الفاتح',
  'Aperçu': 'معاينة',
  'Sélectionnez votre thème préféré': 'اختر المظهر المفضل لديك',
  'Exemple de texte de sous-titre': 'مثال على نص العنوان الفرعي',
  'Basculer entre le mode clair et sombre': 'التبديل بين الوضع الفاتح والداكن',


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
  'Explorer': 'استكشاف',
  'Accueil': 'الصفحة الرئيسية',
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
  'Thème': 'المظهر',
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
  'Version 1.0.0': 'الإصدار 1.0.0',
  'Préférences': 'التفضيلات',
  'Support': 'الدعم',
  'Besoin d\'aide avec les paramètres ? Contactez notre support technique au 0549819905': 'بحاجة إلى مساعدة مع الإعدادات؟ اتصل بدعمنا الفني على 0549819905',
  'Erreur de chargement': 'خطأ في التحميل',
  'Accepter': 'موافقة',

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
  'Nous sommes là pour vous aider avec tout sur l\'application Ahmini': 'نحن هنا لمساعدتك في كل ما يتعلق بتطبيق Ahmini',
  'Consultez nos questions fréquemment posées ou envoyez-nous un email..': 'تصفح الأسئلة الشائعة أو أرسل لنا بريدًا إلكترونيًا..',
  'FAQ': 'الأسئلة الشائعة',
  'Qu\'est-ce que Ahmini ?': 'ما هي Ahmini؟',
  'Ahmini est une application qui permet aux freelancers de trouver des entreprises pour offrir leurs services, et permet aux entreprises de trouver des freelancers capables de répondre à leurs besoins, tout en sécurisant les transactions grâce à un contrat signé par les deux parties.': 'أهmini هو تطبيق يسمح للعاملين لحسابهم الخاص بالعثور على شركات لتقديم خدماتهم، ويسمح للشركات بالعثور على عاملين مستقلين قادرين على تلبية احتياجاتهم، مع تأمين المعاملات من خلال عقد موقع من الطرفين.',
  'Comment procéder au paiement ?': 'كيف يمكن إجراء الدفع؟','Comment être sûr que l\'entreprise me paiera ?': 'كيف يمكنني التأكد من أن الشركة ستدفع لي؟',
  'Grâce à un contrat signé par l\'entreprise et le freelancer.': 'من خلال عقد موقع من قبل الشركة والفريلانسر.',
  'Comment être sûr que le freelancer accomplira le travail demandé ?': 'كيف يمكنني التأكد من أن الفريلانسر سينجز العمل المطلوب؟',
  'Grâce à un contrat signé par l\'entreprise et le freelancer.': 'من خلال عقد موقع من قبل الشركة والفريلانسر.',
  'Via compte - abonnements, choisir l\'abonnement qui vous convient et procédez au paiement en toute sécurité.': 'من خلال الحساب - الإقرارات، اختر الكفالة التي ستوافق عليها وقم بإجراء الدفع بأمان تام',
  "Ahmini est une application qui permet aux freelances de trouver des entreprises pour offrir leurs services, et permet aux entreprises de trouver des freelances capables de répondre à leurs besoins, tout en sécurisant les transactions grâce à un contrat signé par les deux parties.": 'Ahmini هو تطبيق يسمح للعاملين المستقلين بالعثور على شركات تقدم خدماتهم، ويسمح للشركات بالعثور على مستقلين قادرين على تلبية احتياجاتهم، مع تأمين المعاملات بفضل عقد يوقعه الطرفان.',

  'Comment puis-je demander au freelancer le prix du service ?': 'كيف يمكنني طلب سعر الخدمة من الفريلانسر؟',
  'En expliquant le travail demandé à ce freelancer via le chat, et il pourra proposer un prix.': 'عن طريق شرح العمل المطلوب لهذا الفريلانسر عبر الدردشة، وسيتمكن من اقتراح سعر.',
  'Toujours bloqué ? Nous sommes à un mail près': 'ما زلت عالقًا؟ نحن على بعد بريد إلكتروني واحد فقط',
  'Envoyer un message': 'إرسال رسالة',
};



