/// App-wide strings (splash, main shell, etc.). Use lang 'fr' or 'en'.
String appName(String lang) => 'Nous Deux';
String splashTagline(String lang) =>
    lang == 'fr' ? 'Là où les histoires se rejoignent' : 'Where stories meet';

String mainNoPartnerBubble(String lang) =>
    lang == 'fr'
        ? 'Pas encore de partenaire ? Invitez-le ou invitez-la.'
        : 'No partner yet? Invite them.';

String mainPartnerJoinedSnackbar(String lang) =>
    lang == 'fr'
        ? 'Votre partenaire a rejoint ! Bienvenue à deux.'
        : 'Your partner has joined! Welcome, you two.';

String appSupabaseConfigMessage(String lang) =>
    lang == 'fr'
        ? 'Configurez Supabase : définissez SUPABASE_URL et SUPABASE_ANON_KEY via --dart-define.'
        : 'Configure Supabase: set SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.';
