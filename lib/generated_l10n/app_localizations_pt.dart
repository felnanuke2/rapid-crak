// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Quebra de Senha - Brute Force';

  @override
  String get noResult => 'Sem resultado';

  @override
  String get passwordFound => '✓ SENHA ENCONTRADA';

  @override
  String get passwordNotFound => '✗ NÃO ENCONTRADA';

  @override
  String get statistics => 'ESTATÍSTICAS';

  @override
  String get totalTime => 'Tempo Total';

  @override
  String get attempts => 'Tentativas';

  @override
  String get speed => 'Velocidade';

  @override
  String get state => 'Estado';

  @override
  String get console => 'CONSOLE';

  @override
  String get passwordCopied => 'Senha copiada!';

  @override
  String get copyPassword => 'Copiar Senha';

  @override
  String get newSearch => 'Nova Busca';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get newFile => 'Novo Arquivo';

  @override
  String get loading => 'Carregando...';

  @override
  String get processingPassword => 'Processando...';

  @override
  String get passwordNotFoundMessage =>
      'Senha não encontrada com as configurações atuais.';

  @override
  String get bruteForcingStrategy => 'Estratégia de Força Bruta';

  @override
  String get numbers => 'Números (0-9)';

  @override
  String get lowercase => 'Minúsculas (a-z)';

  @override
  String get uppercase => 'Maiúsculas (A-Z)';

  @override
  String get symbols => 'Símbolos (!@#...)';

  @override
  String get passwordLength => 'Comprimento da Senha';

  @override
  String minMaxCharacters(int min, int max) {
    return '$min - $max caracteres';
  }

  @override
  String get warningLongPasswords =>
      'Atenção: Senhas longas podem levar horas/dias no celular.';

  @override
  String get attackInProgress => 'Ataque em Progresso';

  @override
  String get starting => 'Iniciando...';

  @override
  String get performance => 'PERFORMANCE';

  @override
  String get running => 'RODANDO';

  @override
  String get paused => 'PAUSADO';

  @override
  String get waitingAttempts => 'Aguardando tentativas...';

  @override
  String get configureAttack => 'Configuração do Ataque';

  @override
  String get optimizationTip => 'Dica de Otimização';

  @override
  String get optimizationMessage =>
      'Quanto menos opções de caracteres e menor o comprimento, mais rápido será o ataque.';

  @override
  String get startAttack => 'INICIAR QUEBRA DE SENHA';

  @override
  String get back => 'Voltar';

  @override
  String get selectProtectedFile => 'Selecione um arquivo protegido';

  @override
  String supportedFormats(String formats) {
    return 'Formatos suportados: $formats';
  }

  @override
  String get importFile => 'Importar Arquivo';

  @override
  String get passwordCrackerTitle => '🔐 QUEBRA DE SENHA';

  @override
  String get bruteForceRealTime => 'Força Bruta em Tempo Real';

  @override
  String get invalidConfiguration => 'Configuração inválida';

  @override
  String error(String message) {
    return 'Erro: $message';
  }

  @override
  String get passwordStrength => 'Análise de Força da Senha';

  @override
  String get weakPassword => 'SENHA FRACA';

  @override
  String get moderatePassword => 'SENHA MODERADA';

  @override
  String get strongPassword => 'SENHA FORTE';

  @override
  String get veryStrongPassword => 'SENHA MUITO FORTE';

  @override
  String get weakPasswordMessage =>
      'Esta configuração indica uma senha fraca. O ataque deve ter sucesso rapidamente (menos de 1 minuto).';

  @override
  String moderatePasswordMessage(String minutes) {
    return 'Esta configuração indica uma senha moderada. O ataque pode levar até $minutes minutos.';
  }

  @override
  String strongPasswordMessage(String hours) {
    return 'Esta configuração indica uma senha forte. O ataque pode levar até $hours horas.';
  }

  @override
  String veryStrongPasswordMessage(String duration) {
    return 'Esta configuração indica uma SENHA MUITO FORTE (est. $duration). Força bruta é IMPRATICÁVEL em dispositivos comuns. Este app é efetivo apenas para SENHAS FRACAS (4-6 caracteres).';
  }

  @override
  String veryStrongPasswordMessageYears(String years) {
    return 'Esta configuração indica uma SENHA MUITO FORTE (est. $years anos). Força bruta é IMPRATICÁVEL em dispositivos comuns. Este app é efetivo apenas para SENHAS FRACAS (4-6 caracteres).';
  }

  @override
  String passwordConfigurationInfo(
    int minLength,
    int maxLength,
    int charsetSize,
  ) {
    return 'Configuração: $minLength-$maxLength chars • Charset: $charsetSize caracteres';
  }

  @override
  String get appEffectiveFor =>
      'Este app é mais efetivo para senhas com menos de 7 caracteres.';

  @override
  String estimatedDays(String days) {
    return '$days dias';
  }

  @override
  String get lastPassword => 'Última Senha';

  @override
  String get consoleAttempts => 'Tentativas';

  @override
  String get consoleSpeed => 'Velocidade';

  @override
  String get consoleElapsed => 'Decorrido';

  @override
  String get unsupportedFileExtension =>
      'Arquivo não suportado. Use .zip, .pdf, .rar ou .7z';

  @override
  String get minLengthGreaterThanMax =>
      'Comprimento mínimo não pode ser maior que o máximo';

  @override
  String get maxLengthWarning =>
      'Comprimento máximo recomendado é 16 (muito longo)';

  @override
  String passwordsPerSecond(String count) {
    return '$count senhas/seg';
  }

  @override
  String get attemptedLabel => 'testadas';

  @override
  String get noPasswordFound => 'Nenhuma senha encontrada';

  @override
  String attackError(String message) {
    return 'Erro no ataque: $message';
  }

  @override
  String unsupportedFileType(String formats) {
    return 'Tipo de arquivo não suportado. Use: $formats';
  }

  @override
  String get emptyFile => 'Arquivo vazio';

  @override
  String get fileTooLarge => 'Arquivo muito grande (máximo 5GB)';

  @override
  String get fileReadError => 'Não foi possível ler os bytes do arquivo';

  @override
  String fileSelectError(String error) {
    return 'Erro ao selecionar arquivo: $error';
  }
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Quebra de Senha - Brute Force';

  @override
  String get noResult => 'Sem resultado';

  @override
  String get passwordFound => '✓ SENHA ENCONTRADA';

  @override
  String get passwordNotFound => '✗ NÃO ENCONTRADA';

  @override
  String get statistics => 'ESTATÍSTICAS';

  @override
  String get totalTime => 'Tempo Total';

  @override
  String get attempts => 'Tentativas';

  @override
  String get speed => 'Velocidade';

  @override
  String get state => 'Estado';

  @override
  String get console => 'CONSOLE';

  @override
  String get passwordCopied => 'Senha copiada!';

  @override
  String get copyPassword => 'Copiar Senha';

  @override
  String get newSearch => 'Nova Busca';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get newFile => 'Novo Arquivo';

  @override
  String get loading => 'Carregando...';

  @override
  String get processingPassword => 'Processando...';

  @override
  String get passwordNotFoundMessage =>
      'Senha não encontrada com as configurações atuais.';

  @override
  String get bruteForcingStrategy => 'Estratégia de Força Bruta';

  @override
  String get numbers => 'Números (0-9)';

  @override
  String get lowercase => 'Minúsculas (a-z)';

  @override
  String get uppercase => 'Maiúsculas (A-Z)';

  @override
  String get symbols => 'Símbolos (!@#...)';

  @override
  String get passwordLength => 'Comprimento da Senha';

  @override
  String minMaxCharacters(int min, int max) {
    return '$min - $max caracteres';
  }

  @override
  String get warningLongPasswords =>
      'Atenção: Senhas longas podem levar horas/dias no celular.';

  @override
  String get attackInProgress => 'Ataque em Progresso';

  @override
  String get starting => 'Iniciando...';

  @override
  String get performance => 'PERFORMANCE';

  @override
  String get running => 'RODANDO';

  @override
  String get paused => 'PAUSADO';

  @override
  String get waitingAttempts => 'Aguardando tentativas...';

  @override
  String get configureAttack => 'Configuração do Ataque';

  @override
  String get optimizationTip => 'Dica de Otimização';

  @override
  String get optimizationMessage =>
      'Quanto menos opções de caracteres e menor o comprimento, mais rápido será o ataque.';

  @override
  String get startAttack => 'INICIAR QUEBRA DE SENHA';

  @override
  String get back => 'Voltar';

  @override
  String get selectProtectedFile => 'Selecione um arquivo protegido';

  @override
  String supportedFormats(String formats) {
    return 'Formatos suportados: $formats';
  }

  @override
  String get importFile => 'Importar Arquivo';

  @override
  String get passwordCrackerTitle => '🔐 QUEBRA DE SENHA';

  @override
  String get bruteForceRealTime => 'Força Bruta em Tempo Real';

  @override
  String get invalidConfiguration => 'Configuração inválida';

  @override
  String error(String message) {
    return 'Erro: $message';
  }

  @override
  String get passwordStrength => 'Análise de Força da Senha';

  @override
  String get weakPassword => 'SENHA FRACA';

  @override
  String get moderatePassword => 'SENHA MODERADA';

  @override
  String get strongPassword => 'SENHA FORTE';

  @override
  String get veryStrongPassword => 'SENHA MUITO FORTE';

  @override
  String get weakPasswordMessage =>
      'Esta configuração indica uma senha fraca. O ataque deve ter sucesso rapidamente (menos de 1 minuto).';

  @override
  String moderatePasswordMessage(String minutes) {
    return 'Esta configuração indica uma senha moderada. O ataque pode levar até $minutes minutos.';
  }

  @override
  String strongPasswordMessage(String hours) {
    return 'Esta configuração indica uma senha forte. O ataque pode levar até $hours horas.';
  }

  @override
  String veryStrongPasswordMessage(String duration) {
    return 'Esta configuração indica uma SENHA MUITO FORTE (est. $duration). Força bruta é IMPRATICÁVEL em dispositivos comuns. Este app é efetivo apenas para SENHAS FRACAS (4-6 caracteres).';
  }

  @override
  String veryStrongPasswordMessageYears(String years) {
    return 'Esta configuração indica uma SENHA MUITO FORTE (est. $years anos). Força bruta é IMPRATICÁVEL em dispositivos comuns. Este app é efetivo apenas para SENHAS FRACAS (4-6 caracteres).';
  }

  @override
  String passwordConfigurationInfo(
    int minLength,
    int maxLength,
    int charsetSize,
  ) {
    return 'Configuração: $minLength-$maxLength chars • Charset: $charsetSize caracteres';
  }

  @override
  String get appEffectiveFor =>
      'Este app é mais efetivo para senhas com menos de 7 caracteres.';

  @override
  String estimatedDays(String days) {
    return '$days dias';
  }

  @override
  String get lastPassword => 'Última Senha';

  @override
  String get consoleAttempts => 'Tentativas';

  @override
  String get consoleSpeed => 'Velocidade';

  @override
  String get consoleElapsed => 'Decorrido';

  @override
  String get unsupportedFileExtension =>
      'Arquivo não suportado. Use .zip, .pdf, .rar ou .7z';

  @override
  String get minLengthGreaterThanMax =>
      'Comprimento mínimo não pode ser maior que o máximo';

  @override
  String get maxLengthWarning =>
      'Comprimento máximo recomendado é 16 (muito longo)';

  @override
  String passwordsPerSecond(String count) {
    return '$count senhas/seg';
  }

  @override
  String get attemptedLabel => 'testadas';

  @override
  String get noPasswordFound => 'Nenhuma senha encontrada';

  @override
  String attackError(String message) {
    return 'Erro no ataque: $message';
  }

  @override
  String unsupportedFileType(String formats) {
    return 'Tipo de arquivo não suportado. Use: $formats';
  }

  @override
  String get emptyFile => 'Arquivo vazio';

  @override
  String get fileTooLarge => 'Arquivo muito grande (máximo 5GB)';

  @override
  String get fileReadError => 'Não foi possível ler os bytes do arquivo';

  @override
  String fileSelectError(String error) {
    return 'Erro ao selecionar arquivo: $error';
  }
}
