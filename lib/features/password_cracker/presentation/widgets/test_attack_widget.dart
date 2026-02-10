import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../state/password_cracker_provider.dart';
import '../../domain/services/rust_password_cracker_service.dart';
import '../../domain/entities/attack_entities.dart';

/// Widget de exemplo para testar a integração Rust
class TestAttackWidget extends StatelessWidget {
  const TestAttackWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PasswordCrackerProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Teste de Ataque Rust'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Botão para selecionar arquivo
                ElevatedButton.icon(
                  onPressed: provider.isAttackRunning
                      ? null
                      : () => _pickFile(context, provider),
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Selecionar arquivo ZIP'),
                ),
                const SizedBox(height: 16),

                // Informações do arquivo
                if (provider.hasLoadedFile) ...[
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.folder_zip),
                      title: Text(provider.loadedFile!.name),
                      subtitle: Text(
                          '${(provider.loadedFile!.sizeInBytes / 1024).toStringAsFixed(2)} KB'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Configuração
                  Text('Configuração do Ataque',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration:
                              const InputDecoration(labelText: 'Min Length'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final min = int.tryParse(value);
                            if (min != null) {
                              provider.updatePasswordLength(minLength: min);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration:
                              const InputDecoration(labelText: 'Max Length'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final max = int.tryParse(value);
                            if (max != null) {
                              provider.updatePasswordLength(maxLength: max);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Estratégia
                  CheckboxListTile(
                    title: const Text('Lowercase (a-z)'),
                    value: provider.configuration.strategy.lowercase,
                    onChanged: (value) {
                      provider.updateStrategy(
                        provider.configuration.strategy
                            .copyWith(lowercase: value),
                      );
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Uppercase (A-Z)'),
                    value: provider.configuration.strategy.uppercase,
                    onChanged: (value) {
                      provider.updateStrategy(
                        provider.configuration.strategy
                            .copyWith(uppercase: value),
                      );
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Numbers (0-9)'),
                    value: provider.configuration.strategy.numbers,
                    onChanged: (value) {
                      provider.updateStrategy(
                        provider.configuration.strategy.copyWith(numbers: value),
                      );
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Symbols (!@#...)'),
                    value: provider.configuration.strategy.symbols,
                    onChanged: (value) {
                      provider.updateStrategy(
                        provider.configuration.strategy.copyWith(symbols: value),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Botão de ataque
                  if (!provider.isAttackRunning)
                    ElevatedButton.icon(
                      onPressed: () => _startAttack(context, provider),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Iniciar Ataque'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Ataque em progresso...'),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Estatísticas em tempo real
                  if (provider.currentStats != null) ...[
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estatísticas',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                                'Tentativas: ${provider.currentStats!.attemptedCount}'),
                            Text(
                                'Velocidade: ${provider.currentStats!.passwordsPerSecond.toStringAsFixed(0)} senhas/s'),
                            Text(
                                'Tempo: ${provider.currentStats!.elapsedTime.inSeconds}s'),
                            if (provider.currentStats!.currentPassword != null)
                              Text(
                                  'Testando: ${provider.currentStats!.currentPassword}'),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Resultado
                  if (provider.lastResult != null) ...[
                    Card(
                      color: provider.hasSuccessfulResult
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.hasSuccessfulResult
                                  ? '✅ Senha Encontrada!'
                                  : '❌ Falha',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: provider.hasSuccessfulResult
                                        ? Colors.green.shade900
                                        : Colors.red.shade900,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            if (provider.lastResult!.password != null)
                              Text(
                                'Senha: ${provider.lastResult!.password}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            Text(
                                'Total de tentativas: ${provider.lastResult!.totalAttempts}'),
                            Text(
                                'Tempo total: ${provider.lastResult!.totalTime.inSeconds}s'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.resetAttack(),
                      child: const Text('Resetar'),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFile(
      BuildContext context, PasswordCrackerProvider provider) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      provider.setLoadedFile(LoadedFile(
        name: file.name,
        path: file.path ?? '',
        bytes: file.bytes!,
        sizeInBytes: file.bytes!.length,
        loadedAt: DateTime.now(),
      ));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Arquivo carregado: ${file.name}')),
        );
      }
    }
  }

  Future<void> _startAttack(
      BuildContext context, PasswordCrackerProvider provider) async {
    if (!provider.hasLoadedFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um arquivo primeiro')),
      );
      return;
    }

    if (!provider.configuration.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuração inválida')),
      );
      return;
    }

    try {
      await RustPasswordCrackerService.executeAttack(
        fileBytes: provider.loadedFile!.bytes,
        config: provider.configuration,
        provider: provider,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }
}
