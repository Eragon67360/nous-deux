/// Pairing screen strings. Use lang 'fr' or 'en'.
String pairingInviteTitle(String lang) =>
    lang == 'fr' ? 'Inviter votre partenaire' : 'Invite your partner';
String pairingIntro(String lang) => lang == 'fr'
    ? 'Générez un code et montrez-le à votre partenaire, qui pourra scanner le QR code ou taper les 6 caractères.'
    : 'Generate a code and show it to your partner. They can scan the QR code or type the 6 characters.';
String pairingGenerateCode(String lang) =>
    lang == 'fr' ? 'Générer un code' : 'Generate a code';
String pairingScanQrPrompt(String lang) => lang == 'fr'
    ? 'À scanner avec le téléphone de votre partenaire :'
    : "Scan this with your partner's phone:";
String pairingOrEnterCode(String lang) =>
    lang == 'fr' ? 'Ou tapez ce code :' : 'Or type this code:';
String pairingAlreadyHaveCode(String lang) => lang == 'fr'
    ? 'Votre partenaire vous a déjà invité ?'
    : 'Already invited by your partner?';
String pairingJoinWithCode(String lang) =>
    lang == 'fr' ? "J'ai un code" : 'I have a code';
String pairingScanQr(String lang) =>
    lang == 'fr' ? 'Scanner un QR code' : 'Scan a QR code';
String pairingAlreadyPaired(String lang) => lang == 'fr'
    ? "Vous êtes déjà en couple dans l'app. Retour à l'accueil…"
    : "You're already paired. Taking you back…";
String pairingError(String lang) =>
    lang == 'fr' ? "Ça n'a pas marché. Réessayez." : "That didn't work. Try again.";

String pairingJoinTitle(String lang) =>
    lang == 'fr' ? 'Rejoindre votre partenaire' : 'Join your partner';
String pairingJoinInstructions(String lang) => lang == 'fr'
    ? 'Tapez le code à 6 caractères affiché sur le téléphone de votre partenaire.'
    : "Type the 6-character code shown on your partner's phone.";
String pairingJoinCodeLabel(String lang) =>
    lang == 'fr' ? 'Code' : 'Code';
String pairingJoinCodeHint(String lang) => 'ABC123';
String pairingJoinButton(String lang) =>
    lang == 'fr' ? 'Rejoindre' : 'Join';
String pairingJoinErrorCode(String lang) => lang == 'fr'
    ? 'Tapez le code de votre partenaire.'
    : "Type your partner's code.";
String pairingJoinErrorUsed(String lang) => lang == 'fr'
    ? 'Ce code a déjà servi. Demandez-en un nouveau à votre partenaire.'
    : 'This code has already been used. Ask your partner for a new one.';
String pairingJoinErrorOwnCode(String lang) => lang == 'fr'
    ? "C'est votre propre code : c'est à votre partenaire de le saisir."
    : "That's your own code. Your partner needs to enter it.";
String pairingJoinErrorInvalid(String lang) => lang == 'fr'
    ? 'Ce code ne correspond à aucune invitation. Vérifiez-le avec votre partenaire.'
    : "That code doesn't match an invite. Check it with your partner.";

String pairingScanTitle(String lang) =>
    lang == 'fr' ? 'Scanner le QR code' : 'Scan the QR code';
String pairingScanConnecting(String lang) =>
    lang == 'fr' ? 'Connexion…' : 'Connecting…';
