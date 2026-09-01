# Plano de trabalho

Última atualização: 2026-09-01.

Este arquivo registra o andamento para o trabalho continuar mesmo em outra
conversa.

## Hardening inicial

- [x] Auditar estrutura, scripts, configurações e peso do repositório.
- [x] Criar a branch `refactor/repo-hardening`.
- [x] Corrigir o bloco incompleto do i3status.
- [x] Fazer os scripts GPG propagarem erros e recusarem sobrescrita.
- [x] Remover caminhos absolutos das ações do i3 e do Thunar.
- [x] Adicionar validação local e GitHub Actions.
- [x] Remover o tema Papirus copiado do sistema e torná-lo dependência.
- [x] Remover cópias de configuração e pacotes de tema duplicados.
- [x] Corrigir permissões executáveis nos dotfiles e imagens pessoais.
- [x] Remover bookmarks locais e adicionar regras para arquivos temporários.
- [x] Documentar instalação, componentes e atribuições.

## Próximas etapas

- [ ] Detectar automaticamente interface de rede e sensor de temperatura.
- [ ] Criar instalador com modo simulação, backup e restauração.
- [ ] Separar preferências pessoais das configurações reutilizáveis.
- [ ] Revisar e reduzir os arquivos vendorizados do tema Nordic/Kvantum.
- [ ] Decidir se o fork será mantido ou convertido em projeto independente.
- [ ] Avaliar reescrita do histórico para remover blobs antigos; exige backup e
      `force push`, portanto não será feita sem autorização explícita.
