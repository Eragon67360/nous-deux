/// App-wide strings (splash, main shell, etc.). Use lang 'fr' or 'en'.
String appName(String lang) => 'Nous Deux';
String splashTagline(String lang) =>
    lang == 'fr' ? 'Là où les histoires se rejoignent' : 'Where stories meet';

String mainNoPartnerBubble(String lang) => lang == 'fr'
    ? "Votre partenaire n'est pas encore là. Envoyez-lui une invitation."
    : "Your partner isn't here yet. Send them an invite.";

String pairingCelebrationTitle(String lang) =>
    lang == 'fr' ? 'Vous voilà deux.' : "It's the two of you now.";

String pairingCelebrationBody(String lang) => lang == 'fr'
    ? 'Votre partenaire vous a rejoint. Ce que vous ajoutez ici, vous le partagez à deux.'
    : 'Your partner is in. Whatever you add here, you now share.';

String appSupabaseConfigMessage(String lang) =>
    lang == 'fr'
        ? 'Configurez Supabase : définissez SUPABASE_URL et SUPABASE_ANON_KEY via --dart-define.'
        : 'Configure Supabase: set SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.';
