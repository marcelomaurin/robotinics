---
title: "Robotinics Rev. 3"
subtitle: "Robótica, IoT e Inteligência Artificial com Arduino, Raspberry Pi e TCHATGPT"
author: "Marcelo Maurin Martins"
edition: "Terceira edição revista e ampliada"
date: "2026"
language: "pt-BR"
dedication: "À minha querida esposa, Daniela Machado. Amor eterno."
---

# Apresentação da terceira edição

O Robotinics nasceu como um projeto multidisciplinar: um robô terrestre, aberto à experimentação, construído com peças impressas em 3D, eletrônica acessível, Arduino, Raspberry Pi e software livre. A primeira edição documentou uma jornada real de pesquisa e construção. Esta terceira edição preserva esse valor histórico, mas reorganiza o material para que ele volte a funcionar como manual técnico.

A mudança principal não é apenas trocar versões de programas. A arquitetura foi revista para separar responsabilidades, corrigir cálculos e incorporar inteligência artificial sem entregar a um modelo de linguagem o controle irrestrito do robô. O Arduino continua responsável por tarefas determinísticas e de tempo real. O Raspberry Pi coordena serviços, sensores e comunicação. O projeto TCHATGPT fornece a camada de modelos de linguagem, agentes, voz, visão, memória, RAG e observabilidade. Entre a decisão da IA e qualquer atuador existe uma camada obrigatória de validação e segurança.

Esta edição foi construída sobre duas referências congeladas:

| Projeto | Referência editorial | Finalidade |
|---|---|---|
| Robotinics | commit `61d2a19d10e6701e27e46181e1a6c740b8ee4e30` | Mecânica, eletrônica, firmware e acervo histórico |
| TCHATGPT | commit `15d5e1a7780088701716896cfe9fb3afe0e7b71a` | Componentes Lazarus/Free Pascal para IA e integração |

O congelamento das referências não impede evolução. Ele apenas garante que o leitor consiga relacionar texto e código. Novas versões podem ser adotadas depois que as diferenças forem verificadas.

> [!WARNING]
> Este é um projeto educacional e experimental. Ele inclui motores, baterias de íons de lítio, ferramentas, soldagem e partes móveis. Não trabalhe energizado, não monte carregadores de lítio improvisados e não faça ligações à rede elétrica com base apenas neste livro. Use módulos certificados, proteção adequada e supervisão de pessoa qualificada.

## O que foi corrigido

As correções desta edição incluem, entre outras:

- capacidade de células em série, tensão nominal e tensão máxima do conjunto 3S;
- processo de carga CC/CV, proteção e balanceamento de células de lítio;
- uso correto do multímetro para tensão e corrente;
- distinção entre força, torque, potência, energia e capacidade;
- cálculos de tração, aclive e torque dos braços;
- corrente de LED e dimensionamento do resistor limitador;
- definição de contatos normalmente aberto e normalmente fechado de relés;
- limites reais de conversores buck e separação das fontes de motores, servos e lógica;
- descrição do L298N, controle de velocidade por PWM e limitações do componente;
- frequência do HC-SR04, exemplos de código e requisitos de temporização;
- problemas de segurança e memória nos servidores C/C++ históricos;
- conflito de portas, comandos e arquivos ausentes no repositório atual;
- práticas antigas de Linux, banco de dados, PHP, OpenCV, voz e acesso remoto;
- navegação, referências, terminologia e organização editorial.

Uma matriz detalhada aparece no Apêndice C.

## Como usar este livro

O projeto é dividido em cinco partes. A primeira define requisitos, arquitetura e segurança. A segunda trata de mecânica, alimentação e eletrônica. A terceira apresenta firmware, Linux e comunicação. A quarta integra o TCHATGPT. A quinta orienta montagem, testes e evolução.

O leitor não precisa instalar todas as ferramentas para montar o robô. Quem deseja apenas reproduzir o protótipo pode usar os arquivos prontos. Quem pretende alterar peças, placas ou software deve trabalhar com as fontes versionadas. Em ambos os casos, cada etapa termina com critérios de aceitação: não avance enquanto o subsistema atual não estiver estável.

## Convenções

- Valores de tensão são indicados em volts (V), corrente em ampères (A), potência em watts (W), energia em watt-hora (Wh), força em newtons (N) e torque em newton-metro (N·m).
- Exemplos numéricos são didáticos. Quando um componente real tiver ficha técnica diferente, prevalece a ficha técnica.
- Comandos literais, nomes de arquivos e identificadores aparecem em fonte monoespaçada.
- Trechos marcados como **Experimental** não possuem validação suficiente na plataforma indicada.
- O termo **IA** engloba modelos de linguagem, visão, voz, classificação e agentes. Isso não significa autonomia irrestrita.

# Agradecimentos

Esta obra resulta de anos de estudo, construção e colaboração. Permanecem os agradecimentos de Marcelo Maurin Martins a Deus, à família, aos amigos, aos professores do Centro Paula Souza, da ETEC e da FATEC, e às pessoas que revisaram ou apoiaram o projeto original. A memória do professor Danilo continua homenageada nesta edição.

Também são reconhecidas as comunidades de Arduino, Raspberry Pi, Free Pascal, Lazarus e software livre, cujo trabalho torna possível construir e compartilhar projetos como o Robotinics.

# Parte I - Projeto, arquitetura e segurança

# 1. O Robotinics como plataforma de aprendizagem

## 1.1 Robô, IoT e sistema ciberfísico

Um robô é um sistema eletromecânico capaz de perceber o ambiente, processar informações e produzir ações. Um dispositivo de Internet das Coisas coleta ou recebe dados e os troca com outros sistemas. O Robotinics pertence aos dois grupos: possui sensores, atuadores, processamento local, comunicação em rede e serviços que podem ser integrados a aplicações externas.

A definição é útil porque evita reduzir o projeto a uma única placa. O comportamento emerge da cooperação entre estrutura mecânica, alimentação, eletrônica, firmware, sistema operacional e aplicações. Uma falha de energia pode parecer erro de software. Ruído de motor pode corromper uma leitura de sensor. Um atraso de rede pode tornar perigoso um comando de movimento. Por isso a unidade de projeto é o sistema completo.

## 1.2 Objetivos da Rev. 3

A terceira edição adota os seguintes objetivos verificáveis:

1. Manter o robô controlável mesmo quando a rede ou a IA estiver indisponível.
2. Impedir que texto livre seja convertido diretamente em sinal de motor.
3. Permitir descoberta determinística dos comandos publicados pelo firmware.
4. Separar energia de tração, servos e lógica.
5. Registrar versão, estado e falhas de cada subsistema.
6. Executar testes por etapas antes da montagem completa.
7. Oferecer modos local e remoto de IA sem obrigar o leitor a usar um provedor específico.
8. Preservar compatibilidade com o acervo mecânico e com comandos históricos quando isso não comprometer a segurança.

## 1.3 Público-alvo

O livro atende estudantes, professores, makers e desenvolvedores que desejam compreender a integração entre áreas. Não pressupõe experiência profissional em todas elas, mas exige cuidado. Um iniciante pode reproduzir as etapas de baixo risco; atividades envolvendo bateria, alta corrente, ferramentas ou alterações estruturais devem contar com orientação adequada.

Para programadores, o Robotinics oferece um caso real de sistemas embarcados, protocolos, Lazarus, Free Pascal, C/C++, Linux, visão, voz e IA. Para profissionais de eletrônica e mecânica, mostra como transformar componentes físicos em um sistema observável e programável.

## 1.4 Organização do repositório

No snapshot adotado, os arquivos principais encontram-se em:

| Área | Caminho de referência | Conteúdo |
|---|---|---|
| Mecânica | `Mecanic/solidwork` e `Mecanic/stl` | Montagens, peças e arquivos para impressão 3D |
| Eletrônica | `Eletronic/eagle`, `Eletronic/pcb` | Placas, desenhos e arquivos históricos de fabricação |
| Arduino | `Software/arduino` | Firmware principal e firmware da cabeça |
| Raspberry | `Software/raspberry` | Serviços, câmera, voz e aplicações históricas |
| Banco e web | `Software/database` e `Software/site` | Scripts e interface histórica |
| Livro | `docs` | PDF da edição anterior |

Algumas ferramentas Lazarus citadas na edição anterior foram removidas do branch principal em 2022. Elas permanecem recuperáveis no histórico, mas não devem ser apresentadas como se estivessem disponíveis no clone atual. A Rev. 3 substitui seu papel por exemplos baseados nos pacotes modulares do TCHATGPT.

## 1.5 Estratégia de documentação

Conceitos, cálculos, arquitetura e critérios de teste pertencem ao livro. Sequências de instalação que mudam rapidamente devem permanecer em documentação versionada no repositório. Essa divisão reduz obsolescência: o livro ensina por que e como validar; o repositório informa o comando exato compatível com determinada versão.

Antes de iniciar, registre em uma ficha de construção:

- revisão mecânica das peças;
- modelo das placas Arduino e Raspberry Pi;
- modelo, química e capacidade declarada da bateria;
- modelos dos motores e servos;
- versão do firmware;
- commit dos projetos Robotinics e TCHATGPT;
- sistema operacional e arquitetura;
- provedor ou servidor local de IA;
- resultados dos testes de bancada.

# 2. Arquitetura da terceira edição

## 2.1 Separação de responsabilidades

A arquitetura utiliza camadas. O Arduino executa controle de baixo nível: motores, servos, leituras simples, temporização, limites e parada. O Raspberry Pi executa serviços do robô: comunicação, captura de sensores de maior volume, supervisão e integração. O TCHATGPT interpreta intenção, organiza contexto e coordena componentes de IA. A interface humana apresenta solicitações e confirma ações sensíveis.

[FIGURE:architecture]

Essa separação é deliberada. Modelos de linguagem são probabilísticos e podem produzir uma resposta incorreta. Motores exigem comportamento previsível. O modelo pode sugerir uma ação estruturada; somente o validador decide se a ação está no catálogo, se os parâmetros estão no intervalo e se o estado do robô permite executá-la.

## 2.2 Caminho de um comando

O caminho seguro de uma solicitação é:

1. O usuário fala ou digita uma intenção.
2. O sistema converte a entrada em texto e inclui apenas o contexto necessário.
3. O agente solicita ao modelo uma resposta em formato estruturado.
4. Um parser valida a estrutura; texto fora do contrato não é executado.
5. O comando é comparado ao catálogo descoberto por `MAN`.
6. A política de segurança valida estado, parâmetros, limites e necessidade de confirmação.
7. O usuário confirma ações físicas quando exigido.
8. O comando é enviado ao Arduino.
9. O firmware aplica seus próprios limites e watchdog.
10. A telemetria confirma o resultado; o agente informa o usuário.

[FIGURE:command_pipeline]

O modelo nunca é a única barreira. Se ele inventar um comando, o catálogo bloqueia. Se usar um parâmetro fora da faixa, o validador bloqueia. Se a comunicação parar, o watchdog interrompe o movimento. Se um obstáculo for detectado, o firmware pode parar sem consultar a IA.

## 2.3 Perfis de implantação

### Perfil A - controlador validado

O aplicativo Lazarus com TCHATGPT roda em Windows x64 ou Linux x64. O Raspberry Pi atua como gateway e computador de bordo. É o perfil recomendado para a primeira montagem porque essas plataformas possuem melhor evidência de suporte no projeto TCHATGPT.

### Perfil B - IA embarcada no Raspberry Pi

O aplicativo Lazarus e os pacotes compatíveis rodam no Raspberry Pi ARM64. O modelo pode ser remoto ou local. No snapshot usado nesta edição, ARM64 está classificado como experimental; portanto, este perfil exige compilação, teste de dependências e validação de cada componente antes de controlar atuadores.

### Perfil C - operação local sem nuvem

O TCHATGPT usa um endpoint OpenAI-compatible local, como llama.cpp ou neural-api. Esse perfil evita enviar dados do robô a um provedor externo, mas exige memória, armazenamento e capacidade computacional compatíveis com o modelo. Em hardware limitado, um modelo pequeno pode servir para classificação e comandos curtos, enquanto visão e voz usam componentes especializados.

## 2.4 Estados operacionais

O robô trabalha com quatro estados mínimos:

| Estado | Movimento | Comandos de consulta | Transição permitida |
|---|---:|---:|---|
| `DISARMED` | Bloqueado | Permitidos | Para `ARMED` após verificação e confirmação |
| `ARMED` | Permitido dentro de limites | Permitidos | Para `EXECUTING`, `DISARMED` ou `FAULT` |
| `EXECUTING` | Somente ação corrente | Telemetria permitida | Retorna a `ARMED` ou vai a `FAULT` |
| `FAULT` | Bloqueado e saída segura | Diagnóstico permitido | Para `DISARMED` após correção e reset |

[FIGURE:safety_states]

`STOP` e `DISARM` devem ser aceitos em qualquer estado. A perda de heartbeat, estouro de tempo, subtensão crítica, sobrecorrente ou acionamento do botão de emergência conduz a uma saída segura sem depender do Raspberry Pi.

## 2.5 Interfaces

O protocolo entre controlador e Arduino é textual, delimitado por linha e adequado à depuração em terminal. A versão de produção pode evoluir para frames com tamanho, sequência e verificação de integridade, mas deve manter um modo de diagnóstico legível.

Entre serviços de rede, prefira conexões autenticadas, bind restrito e mensagens com tamanho limitado. Os servidores históricos que aceitavam comandos em qualquer interface e encaminhavam dados ao shell não fazem parte da arquitetura recomendada.

# 3. Segurança e método de trabalho

## 3.1 Hierarquia de segurança

Segurança é implementada em camadas independentes:

1. **Mecânica:** proteção de engrenagens, fixação, centro de gravidade e ausência de pontos de esmagamento acessíveis.
2. **Elétrica:** fusível, chave geral, proteção contra inversão, BMS, fios dimensionados e conectores adequados.
3. **Firmware:** limites, timeout, watchdog, parada por obstáculo e estado desarmado na inicialização.
4. **Aplicação:** catálogo de comandos, intervalos, confirmação, autenticação e registro.
5. **IA:** prompt restrito, saída estruturada, limite de ações e ausência de acesso direto ao sistema operacional.
6. **Operação:** área livre, supervisão, botão de emergência e procedimento de teste.

Nenhuma camada autoriza remover a seguinte. Um prompt bem escrito não substitui o watchdog; um fusível não substitui o limite de corrente no projeto; uma confirmação na tela não substitui o botão físico.

## 3.2 Regras de bancada

- Faça os primeiros testes com as rodas suspensas.
- Use uma fonte de bancada com limitação de corrente antes da bateria.
- Conecte um subsistema por vez.
- Nunca ajuste fiação com o sistema energizado.
- Mantenha o botão de emergência ao alcance.
- Teste `STOP` antes de qualquer comando de movimento.
- Para servos, remova braços e cargas nos primeiros movimentos.
- Não carregue células de lítio dentro do robô sem projeto térmico e proteção adequados.
- Não deixe o conjunto carregando sem supervisão.
- Registre corrente de repouso, corrente de pico e temperatura.

## 3.3 Controle de mudanças

Cada alteração deve responder quatro perguntas:

1. Qual requisito motivou a mudança?
2. Quais arquivos e componentes foram alterados?
3. Como a mudança foi testada?
4. Como retornar à versão anterior?

Firmware, aplicação e documento devem informar versão. Uma versão publicada do livro deve apontar para uma tag do repositório; apontar apenas para `main` ou `master` torna a reprodução dependente de mudanças futuras.

## 3.4 Critérios de conclusão por etapa

Uma etapa está concluída quando:

- a montagem corresponde ao desenho ou a uma alteração registrada;
- não existem fios soltos, curto visível ou aquecimento inesperado;
- o consumo está dentro do orçamento;
- todos os comandos esperados respondem;
- falhas simuladas levam a estado seguro;
- os resultados foram registrados com data e versão;
- o próximo subsistema pode ser adicionado sem esconder falhas anteriores.

## 3.5 Segurança de credenciais e dados

Chaves de API não devem ser gravadas no repositório nem em um `settings.ini` legível. O exemplo do agente serial do TCHATGPT possui opção histórica de salvar token em texto claro; esta edição não adota essa opção. Use variável de ambiente, cofre do sistema operacional ou arquivo protegido fora da pasta do projeto.

Dados de câmera, microfone, telemetria e conversas podem conter informações pessoais. Quando um provedor remoto for usado, informe o operador, envie apenas o necessário e aplique política de retenção. Para uso educacional, prefira ambientes controlados e dados sem identificação.

## 3.6 Limitações declaradas

O Robotinics não é equipamento médico, industrial certificado, veículo para transporte de pessoas nem plataforma de segurança crítica. O uso em outro contexto exige análise de risco, normas aplicáveis e validação profissional. Componentes baratos e clones podem ter especificações diferentes; sempre meça o exemplar real.

# Parte II - Mecânica, energia e eletrônica

# 4. Dimensionamento mecânico

## 4.1 Requisitos antes da escolha dos motores

O motor não deve ser escolhido apenas por uma indicação comercial de torque. Primeiro defina massa, diâmetro das rodas, velocidade, inclinação máxima, tipo de piso, aceleração desejada e número de rodas motrizes. Depois calcule o esforço necessário e aplique margem.

Força e torque não são a mesma grandeza. Força é medida em newtons. Torque é o produto da força pela distância perpendicular ao eixo e é medido em newton-metro. Uma força de 10 N aplicada a 0,05 m do eixo produz 0,5 N·m.

## 4.2 Forças de movimento

Em uma subida com ângulo `θ`, a parcela do peso contrária ao movimento é:

```text
F_aclive = m × g × sen(θ)
```

A resistência aproximada ao rolamento é:

```text
F_rolamento = Crr × m × g × cos(θ)
```

Para acelerar:

```text
F_aceleração = m × a
```

Em baixa velocidade, o arrasto aerodinâmico do Robotinics tende a ser pequeno em relação às demais parcelas, mas pode ser incluído quando necessário. A força total de projeto é a soma das parcelas relevantes. O torque requerido nas rodas é:

```text
T_total = (F_total × raio_da_roda) / eficiência
```

Divida o resultado entre as rodas realmente motrizes. A eficiência representa perdas de transmissão, deformação, mancais e contato com o piso. Não use 100%.

## 4.3 Exemplo corrigido de tração

Considere um robô de 12 kg, duas rodas motrizes, raio de 0,05 m, rampa de 5°, coeficiente de rolamento estimado em 0,03, aceleração de 0,2 m/s² e eficiência global de 70%.

| Parcela | Cálculo | Resultado aproximado |
|---|---|---:|
| Aclive | `12 × 9,81 × sen(5°)` | 10,26 N |
| Rolamento | `0,03 × 12 × 9,81 × cos(5°)` | 3,52 N |
| Aceleração | `12 × 0,2` | 2,40 N |
| Total | soma | 16,18 N |

O torque total de eixo é aproximadamente `(16,18 × 0,05) / 0,70 = 1,16 N·m`. Com duas rodas motrizes, cada conjunto motor-redutor precisa fornecer cerca de `0,58 N·m` na condição calculada. Aplicando fator de segurança 2, a meta passa a aproximadamente `1,16 N·m` por roda, ou cerca de `11,8 kgf·cm`.

Esse valor deve ser comparado ao torque contínuo do conjunto, não apenas ao torque de travamento. Operar continuamente perto do stall aquece o motor, aumenta o consumo e reduz a vida útil. Confirme também a velocidade depois da redução.

## 4.4 Aderência e limite de tração

Mesmo um motor forte não move o robô se a roda patinar. A força máxima transferível depende da carga normal sobre as rodas motrizes e do coeficiente de atrito. Bateria e componentes pesados devem ser posicionados baixos e distribuídos para manter estabilidade e aderência, sem sobrecarregar um único apoio.

Faça um ensaio de rampa com incrementos pequenos. Registre inclinação, corrente dos motores, velocidade, temperatura e ocorrência de patinação. Esse ensaio valida simultaneamente o cálculo mecânico e o orçamento elétrico.

## 4.5 Torque dos braços

Para uma articulação, some o momento produzido por cada massa em relação ao eixo:

```text
T_estático = Σ (massa_i × g × distância_i)
```

A distância é medida entre o eixo e o centro de massa do item. Para o ombro, entram a massa do braço, do antebraço, da garra, dos servos instalados depois do eixo e da carga. A pior condição normalmente ocorre com o braço horizontal.

Exemplo: elo de 0,25 kg com centro de massa a 0,10 m; conjunto distal de 0,20 kg com centro a 0,28 m; carga de 0,10 kg a 0,40 m.

```text
T = (0,25 × 9,81 × 0,10)
  + (0,20 × 9,81 × 0,28)
  + (0,10 × 9,81 × 0,40)
  ≈ 1,19 N·m ≈ 12,1 kgf·cm
```

Esse é apenas o torque estático. Partida, parada, folga, impacto e desalinhamento exigem margem. Com fator 2,5, a articulação precisaria de aproximadamente `3,0 N·m`, ou `30,6 kgf·cm`. Portanto, um servo anunciado com 10 ou 15 kgf·cm não atende essa condição de forma confiável. As soluções são reduzir comprimento ou massa, limitar carga, usar contrapeso/mola, mudar a transmissão ou escolher atuador adequado.

> [!NOTE]
> A unidade tradicional de servos é `kgf·cm`, não `kgf·cm²`. Para conversão aproximada, `1 kgf·cm = 0,0981 N·m`.

## 4.6 Centro de gravidade e estabilidade

O centro de gravidade projetado no piso deve permanecer dentro do polígono formado pelos pontos de contato. Braços estendidos deslocam o centro e podem tombar o robô. Avalie as posições extremas no CAD e faça um teste físico com o robô desenergizado.

Mantenha bateria e fontes na região inferior. Limite por software combinações de pose que aproximem o centro de gravidade da borda. A IA pode escolher uma tarefa, mas um planejador determinístico deve rejeitar poses fora do envelope validado.

# 5. Estrutura e montagem mecânica

## 5.1 Acervo mecânico

O repositório contém peças SolidWorks, montagens e arquivos STL. Entre os elementos principais estão a base, suportes de roda, corpo inferior e superior, suporte do Raspberry Pi, cabeça, extensões dos braços e garras. Arquivos STL permitem reprodução sem possuir o software CAD original; os arquivos de montagem permitem alterações mais profundas.

[FIGURE:robot_cad]

Antes de imprimir, verifique:

- unidade de medida e escala;
- revisão e orientação da peça;
- furos, folgas e espessura mínima;
- espaço para porcas, cabeças de parafuso e conectores;
- sentido de carga em relação às camadas;
- interferência entre cabos e partes móveis;
- acesso para manutenção.

## 5.2 Material e impressão

PLA é simples de imprimir e serve para protótipos rígidos, mas pode perder resistência com temperatura e sofrer fratura em encaixes. PETG oferece maior tenacidade e tolerância térmica em muitos cenários. ABS/ASA pode ser útil para peças funcionais, desde que a impressora e o ambiente controlem empenamento e emissões. A escolha depende da carga, temperatura e capacidade de impressão.

Não copie parâmetros de fatiamento sem validar. Registre material, fabricante, diâmetro do bico, altura de camada, número de perímetros, preenchimento e orientação. Para suportes de motor e articulações, perímetros e orientação costumam ser mais importantes que um preenchimento alto e aleatório.

## 5.3 Base

A base deve ser montada e validada antes do corpo. A sequência recomendada é:

1. Inspecionar e desbastar as peças impressas.
2. Montar suportes, motores e rodas sem eletrônica.
3. Verificar paralelismo e giro livre.
4. Posicionar bateria e placas com gabaritos, sem fixação definitiva.
5. Conferir centro de gravidade e acesso à chave geral.
6. Instalar canaletas, prensa-cabos e pontos de aterramento lógico.
7. Fazer teste de rolagem manual.

Rodas desalinhadas aumentam corrente e prejudicam odometria. Meça distância entre eixos em ambos os lados e verifique se a base não está torcida. Rodízios devem apoiar sem elevar uma roda motriz.

## 5.4 Corpo, braços e cabeça

O corpo abriga placas, distribuição e conexões. Monte painéis de forma removível e identifique cada chicote. Braços devem possuir batentes ou limites seguros antes de receber potência. A cabeça recebe câmera, sensores e mecanismos de orientação; evite passar cabos por zonas de pinçamento.

[FIGURE:arm_cad]

Para cada articulação, registre:

| Item | Registro mínimo |
|---|---|
| Zero mecânico | posição física de referência |
| Zero lógico | valor enviado ao servo nessa posição |
| Limite mínimo e máximo | intervalo sem colisão |
| Corrente em vazio | referência para detectar travamento |
| Carga máxima | condição validada, não apenas anunciada |
| Sentido positivo | convenção usada pelo firmware |

## 5.5 Alternativas à impressão 3D

O conceito original permite construir volumes com materiais acessíveis, como chapas, perfis e elementos esféricos revestidos. Qualquer substituição deve preservar fixação, rigidez, acesso e proteção. Isopor não deve ficar exposto a produtos que o dissolvam; revestimentos e adesivos devem ser testados em amostra.

## 5.6 Critérios de aceitação mecânica

- Nenhuma peça trincada ou deformada.
- Parafusos críticos com trava adequada e marca de inspeção.
- Rodas livres e alinhadas.
- Cabos sem esforço durante todo o curso.
- Centro de gravidade estável com braços nas poses permitidas.
- Proteção contra contato acidental com partes móveis.
- Acesso à bateria, fusível e emergência sem desmontagem extensa.

# 6. Alimentação, bateria e distribuição

## 6.1 Grandezas fundamentais

Tensão representa diferença de potencial. Corrente representa fluxo de carga. Potência elétrica em corrente contínua é `P = V × I`. Energia é potência acumulada no tempo e pode ser expressa em Wh. Capacidade de bateria em Ah não é energia por si só; é necessário considerar a tensão.

Na edição anterior, correntes de trilhos diferentes foram somadas sem converter a potência. O procedimento correto é calcular a potência de cada carga no seu trilho, incluir eficiência dos conversores e então estimar a corrente retirada da bateria.

## 6.2 Conjunto 3S

Considere três células de íons de lítio de 3,7 V nominais e 5,2 Ah ligadas em série:

| Propriedade | Resultado |
|---|---:|
| Tensão nominal | `3 × 3,7 = 11,1 V` |
| Tensão máxima de carga | `3 × 4,2 = 12,6 V`, se especificado para a célula |
| Capacidade | `5,2 Ah` |
| Energia nominal aproximada | `11,1 × 5,2 = 57,7 Wh` |

Em série, as tensões se somam e a capacidade em Ah permanece a mesma. O valor de 15,6 Ah corresponderia a três células iguais em paralelo, não em série.

Valores de 4,2 V por célula são comuns, mas a ficha técnica do fabricante é soberana. Química, limite de carga, corrente e temperatura variam. Não misture células de modelos, capacidades, idades ou estados diferentes.

## 6.3 Carga segura

Células de lítio exigem carregador CC/CV compatível com o número de células e um sistema de proteção/balanceamento apropriado. Um BMS protege o conjunto, mas não transforma uma fonte comum em carregador correto. Para 3S, use carregador projetado para 3S e para a química real, com tensão final e corrente dentro da especificação.

Não derive a corrente de carga por uma regra universal como `C/10`. Use o valor recomendado pelo fabricante das células e pelo pack. Células em série não triplicam a capacidade para esse cálculo.

> [!DANGER]
> A Rev. 3 não ensina a construir carregador conectado à rede elétrica. Use equipamento certificado e apropriado ao pack. Célula inchada, danificada, aquecida ou com tensão anormal deve ser isolada e encaminhada conforme orientação local para resíduos perigosos.

## 6.4 BMS, fusível e chave geral

A arquitetura mínima inclui:

1. pack montado de forma segura;
2. BMS/proteção compatível com 3S, corrente e química;
3. fusível próximo ao terminal positivo da bateria;
4. chave geral dimensionada para corrente contínua;
5. distribuição protegida para cada trilho;
6. conectores polarizados e com capacidade adequada.

O fusível protege o condutor e reduz energia de uma falha. Seu valor não deve exceder a capacidade segura dos fios e conectores. Correntes de partida precisam ser consideradas para evitar disparo indevido, sem transformar o fusível em mero fio.

[FIGURE:power_architecture]

## 6.5 Trilhos separados

Motores DC, servos e lógica produzem e toleram ruído de formas diferentes. A Rev. 3 usa trilhos separados:

- **Tração:** tensão compatível com os motores e driver, com proteção própria.
- **Servos:** conversor de alta corrente na tensão permitida pelos servos.
- **Lógica 5 V:** Raspberry Pi e periféricos compatíveis, com margem para picos.
- **Lógica 3,3 V:** sensores ou interfaces que a exijam.

Os terras podem precisar de referência comum para sinais, mas a distribuição deve evitar que corrente de motor atravesse o retorno da lógica. Use topologia de estrela, condutores adequados, desacoplamento e verificação com osciloscópio quando possível.

Uma fonte “5 V/5 A” não é automaticamente suficiente para Raspberry Pi, servos e periféricos. Servos de alto torque podem produzir picos elevados. Dimensione com medições e margem, e nunca alimente vários servos pelo regulador da placa Arduino.

## 6.6 Conversores

Um conversor buck reduz tensão. Ele não consegue regular 12,6 V a partir de uma entrada de 12 V. Para elevar tensão é necessário boost; para operar acima e abaixo da saída, buck-boost. No Robotinics, é preferível escolher arquitetura em que os conversores trabalhem dentro de sua faixa com margem.

Verifique tensão máxima, corrente contínua real, refrigeração, ripple, eficiência e resposta a transientes. A corrente impressa em módulos baratos pode representar pico em condição ideal, não operação contínua.

## 6.7 Autonomia

A autonomia aproximada pode ser estimada por:

```text
tempo_h ≈ (energia_nominal_Wh × eficiência_utilizável) / potência_média_W
```

Com 57,7 Wh, eficiência utilizável global de 80% e consumo médio de 35 W, a estimativa é `(57,7 × 0,8) / 35 ≈ 1,32 h`. Movimento, terreno, temperatura, envelhecimento e limites do BMS reduzem ou alteram o resultado. Valide em ensaio controlado e não descarregue além do limite seguro.

## 6.8 Capacitores e ripple

`20,75 × 10⁻³ F` equivale a `0,02075 F`, isto é, `20.750 µF`; não a 20,75 µF. Em uma fonte retificada, uma aproximação comum é:

```text
C ≈ I / (f_ripple × ΔV)
```

Para 1 A, ripple de 120 Hz e variação de 1 V, `C ≈ 8.333 µF`. Esse exemplo não substitui projeto de fonte, tolerância, ESR, tensão do capacitor e corrente de ripple.

## 6.9 Medição correta

Tensão é medida em paralelo. Corrente é medida em série com a carga ou por sensor apropriado. Colocar o multímetro configurado para corrente diretamente entre positivo e negativo cria um curto de baixa resistência e pode queimar fusível, pontas, circuito ou causar acidente.

Antes de medir:

- confirme bornes e função selecionada;
- comece pela escala adequada;
- desenergize para alterar ligação em série;
- respeite categoria, tensão, corrente e fusível do instrumento;
- use pinça ou sensor quando o método em série não for seguro.

## 6.10 Critérios de aceitação elétrica

- Polaridade e continuidade verificadas sem bateria.
- Fusíveis instalados e identificados.
- Tensão de cada trilho dentro da tolerância, sem carga e sob carga.
- Ripple e queda de tensão aceitáveis durante partida de motor/servo.
- Corrente de repouso e picos registrados.
- Nenhum conector ou fio aquecendo além do esperado.
- BMS e carregador compatíveis e documentados.
- Subtensão e desligamento testados de forma controlada.

# 7. Eletrônica, sensores e atuadores

## 7.1 Arduino e níveis lógicos

O firmware histórico foi desenvolvido para Arduino Mega, cuja lógica é normalmente 5 V. Raspberry Pi usa GPIO de 3,3 V e não tolera 5 V diretamente. Toda ligação entre placas deve considerar nível, direção, corrente e estado durante inicialização. Use conversor de nível quando necessário; nunca confie apenas em uma coincidência observada em bancada.

## 7.2 Driver de motores

O L298N é uma ponte H dupla baseada em transistores bipolares. Ele permite controle de direção e velocidade por PWM aplicado aos pinos de enable. Não fornece isolamento galvânico e apresenta queda de tensão e dissipação relevantes, especialmente em baixa tensão de motor.

Se o projeto for mantido por compatibilidade, meça tensão no motor e temperatura do driver na pior carga. Em uma revisão eletrônica, um driver MOSFET moderno, dimensionado para tensão, corrente de partida e frenagem, tende a oferecer maior eficiência.

O motor aparece com tensões diferentes em trechos históricos. A Rev. 3 não assume 12 V: identifique o modelo instalado e respeite sua ficha técnica. Uma tensão de bateria de 11,1/12,6 V não autoriza ligar diretamente um motor de 3-6 V.

## 7.3 Relés

Contato normalmente aberto (NA/NO) permanece aberto com a bobina desenergizada e fecha quando acionada. Contato normalmente fechado (NF/NC) permanece fechado em repouso e abre quando acionado. Verifique o diagrama do componente, tensão da bobina, corrente dos contatos e necessidade de diodo de roda livre.

## 7.4 LEDs

`0,02 A` corresponde a 20 mA, não 200 mA. O resistor é calculado por:

```text
R = (V_fonte - V_LED) / I_LED
```

Para fonte de 5 V, LED vermelho com queda aproximada de 2 V e corrente desejada de 9 mA, `R ≈ 333 Ω`; 330 Ω é um valor comercial adequado no exemplo. Calcule a potência do resistor por `P = I² × R` e confirme a especificação real do LED.

## 7.5 Sensor ultrassônico

O HC-SR04 utiliza pulsos ultrassônicos em torno de 40 kHz, não 40 Hz. O microcontrolador envia pulso de trigger e mede a duração do echo. A distância aproximada é obtida considerando ida e volta do som:

```text
distância = velocidade_do_som × tempo / 2
```

Faça leituras independentes, descarte timeouts e aplique filtragem. Repetir três vezes a conversão do mesmo tempo não produz três amostras. No Arduino, defina os pinos usados e limite `pulseIn` com timeout para evitar bloqueio prolongado.

O sinal echo de muitos módulos é 5 V. Para Raspberry Pi, use adaptação de nível. Temperatura, ângulo, material e interferência entre sensores afetam o resultado; o ultrassom é auxílio, não única barreira de segurança.

## 7.6 Servos

A biblioteca `Servo` do Arduino usa temporizadores e pode controlar servos em diversos pinos digitais; não é correto afirmar que somente pinos marcados como PWM servem. Entretanto, o uso de temporizadores pode interferir em outras funções, e o número de canais depende da placa e da biblioteca.

Alimente servos por fonte separada e una a referência de sinal de forma planejada. Defina limites mecânicos individuais. Na inicialização, não envie abruptamente uma posição que faça a articulação colidir; carregue calibração, valide e mova com rampa.

## 7.7 Sensores analógicos

Entradas de tensão e corrente devem permanecer dentro da faixa do ADC. Divisores resistivos precisam considerar tolerância e impedância; sensores de corrente precisam de calibração de zero, ganho e ruído. Para calcular média ou RMS, zere acumuladores no início da janela e use amostras distintas.

Um alarme de sobrecorrente deve existir abaixo do nível que danifica fios, driver ou bateria. A resposta rápida pode ficar no firmware; o Raspberry registra e explica o evento.

## 7.8 Desacoplamento e compatibilidade eletromagnética

Instale capacitores de desacoplamento próximos aos circuitos, mantenha loops de corrente pequenos e separe cabos de potência de sinais. Motores com escovas podem exigir supressão no próprio motor. Trance pares de alimentação e retorno quando apropriado e evite usar cabos/conectores de dados sem verificar corrente, queda de tensão e pinagem.

Conector RJ45 pode ser usado como conector físico interno, mas isso não transforma o circuito em Ethernet. Identifique claramente para impedir conexão acidental a uma rede.

## 7.9 Checklist eletrônico

- Tensão e corrente nominal de cada componente confirmadas.
- Níveis de 3,3 V e 5 V compatibilizados.
- Pinos e conectores documentados.
- Driver dimensionado pela corrente de partida.
- Servos alimentados fora do regulador do Arduino.
- Sensores calibrados e com timeout.
- Relés e cargas indutivas com proteção.
- Cabos etiquetados, presos e livres de partes móveis.
- Teste de ruído executado com motores e servos em movimento.

# Parte III - Firmware, Linux e comunicação

# 8. Firmware Robotinics Rev. 3

## 8.1 Por que reorganizar

O sketch histórico demonstra muitos recursos, mas concentra cerca de 1.500 linhas em um único arquivo. Ele usa `String` intensivamente em um microcontrolador com pouca RAM, mistura buffers de várias portas, contém esperas bloqueantes e interpreta comandos com testes de substring. Isso torna possível que um prefixo como `ULTRA` também corresponda a `ULTRA1`, além de dificultar timeout, testes e manutenção.

Também existem defeitos objetivos: definições como `#define PINOGPSRX = 0;` não são macros válidas quando expandidas; uma rotina prepara `sInfo` e imprime outra variável; o recorte de `SERIAL:` usa índice incompatível com o prefixo; a leitura ultrassônica repete a conversão do mesmo tempo; o parser de GPS pode bloquear e exceder o buffer.

A Rev. 3 mantém o valor do firmware original, mas propõe uma arquitetura modular e uma interface estável.

## 8.2 Módulos

| Módulo | Responsabilidade |
|---|---|
| `Config` | pinos, limites e versão da placa |
| `CommandParser` | recepção, tokenização e validação sintática |
| `Safety` | estado, heartbeat, emergência, timeouts e falhas |
| `Drive` | direção, PWM, rampa e frenagem |
| `Servos` | calibração, limites e movimento gradual |
| `Sensors` | ultrassom, corrente, tensão, gás e acelerômetro |
| `Telemetry` | respostas estruturadas e eventos |
| `Manual` | catálogo determinístico publicado por `MAN` |

Em placas pequenas, os módulos podem continuar compilados em um único sketch, mas devem permanecer separados por arquivos ou funções de responsabilidade clara.

## 8.3 Inicialização segura

Ao ligar:

1. Configure pinos de enable em estado inativo antes dos pinos de direção.
2. Desligue motores e mantenha o robô em `DISARMED`.
3. Inicialize serial e sensores com timeout.
4. Carregue calibração validada.
5. Publique versão e motivo de qualquer falha.
6. Somente aceite movimento após `ARM` e verificação das condições locais.

Servos devem iniciar em posição conhecida sem saltos. Quando a posição física não é conhecida, mova lentamente para uma referência segura ou exija procedimento manual.

## 8.4 Entrada serial limitada

Use um buffer fixo, por exemplo 128 bytes. Cada byte recebido é anexado até `LF` ou `CRLF`. Se o limite for excedido, descarte a linha, sinalize `ERR LINE_TOO_LONG` e não execute conteúdo parcial. Cada porta deve possuir seu próprio estado de recepção.

Depois de receber uma linha, separe o primeiro token e compare o comando inteiro, sem procurar substring. Parâmetros são convertidos com detecção de erro e faixa. Uma linha inválida gera erro, nunca comportamento parcial.

```text
Entrada:  MOVEFWD 120 800
Comando:  MOVEFWD
PWM:      120, validado em 0..255
Duração:  800 ms, validada em 1..2000
```

## 8.5 Manual de comandos

O `TAIAgentSerial` do projeto TCHATGPT descobre o catálogo por marcadores e linhas determinísticas. O firmware Rev. 3 deve responder:

```text
MAN-BEGIN
DEVICE: Robotinics Rev3
VERSION: 3.0.0
BAUD: 115200 8N1
COMMAND PING: testa comunicação, sem parâmetros
COMMAND STATUS?: retorna estado, tensão, corrente e falhas
COMMAND ARM: habilita o estado armado após validação local
COMMAND DISARM: desabilita atuadores
COMMAND STOP: interrompe imediatamente o movimento
COMMAND MOVEFWD: MOVEFWD <pwm 0..255> <tempo_ms 1..2000>
COMMAND MOVEBACK: MOVEBACK <pwm 0..255> <tempo_ms 1..2000>
COMMAND TURNLEFT: TURNLEFT <pwm 0..255> <tempo_ms 1..1500>
COMMAND TURNRIGHT: TURNRIGHT <pwm 0..255> <tempo_ms 1..1500>
COMMAND RANGE?: retorna distâncias válidas dos sensores
COMMAND BATTERY?: retorna tensão e estado estimado
COMMAND MAN: publica este manual
MAN-END
```

O agente interpreta somente linhas `COMMAND`. Informações como versão e baud são apresentadas ao operador, mas não criam ações. Comandos desconhecidos permanecem bloqueados. Os aliases históricos `FRENTE`, `RE`, `GESQ`, `GDIR` e `PARA` podem ser mantidos para uso manual, mapeados internamente para a nova API e sujeitos aos mesmos limites.

## 8.6 Watchdog e heartbeat

Movimento deve expirar. Mesmo quando o comando contém duração, o firmware registra o instante de início e interrompe ao atingir o limite. Se a aplicação usar movimento contínuo, ela envia heartbeat periódico; ausência por um intervalo curto, por exemplo 500 ms, conduz a `STOP` e `FAULT` ou `DISARMED`, conforme a política.

O watchdog de hardware deve ser configurado para recuperar travamento do firmware. Após reset por watchdog, o robô volta desarmado e registra a causa. Reiniciar não deve retomar a ação anterior.

## 8.7 Obstáculos e limites locais

O firmware pode bloquear avanço quando um sensor frontal válido indicar distância menor que a margem configurada. Leituras inválidas não devem ser convertidas automaticamente em “caminho livre”. Defina uma política explícita: reduzir velocidade, parar e solicitar nova leitura.

Servos possuem limites por articulação. Corrente ou tempo excessivo sugere travamento e deve interromper a saída. A parada física de emergência deve retirar energia dos atuadores de modo apropriado e informar seu estado à lógica quando possível.

## 8.8 Telemetria

Respostas seguem padrões simples:

```text
OK <comando> [detalhes]
ERR <código> <descrição curta>
STATE <chave>=<valor> ...
EVENT <tipo> <dados>
```

Exemplos:

```text
OK ARM
STATE MODE=ARMED BATTERY_MV=11780 FRONT_MM=640
EVENT STOP REASON=HEARTBEAT_TIMEOUT
ERR RANGE_TIMEOUT SENSOR=FRONT
```

Inclua unidade no nome ou no contrato. `BATTERY_MV=11780` é menos ambíguo que `BATTERY=11.78` sem unidade.

## 8.9 Evitar fragmentação de memória

Em AVR, prefira arrays de `char`, buffers limitados e funções que não criem muitas cópias. Evite concatenar `String` indefinidamente. Conteúdo vindo da serial nunca deve aumentar sem limite. Testes de longa duração precisam observar RAM, estabilidade e recuperação de linhas inválidas.

## 8.10 Testes do firmware

- `STOP` funciona em todos os estados.
- Movimento é recusado em `DISARMED`.
- PWM e duração fora do intervalo são recusados.
- Linha longa não executa fragmento.
- Comando desconhecido é recusado.
- Perda de heartbeat para o movimento.
- Sensor com timeout não congela o loop.
- Reset retorna ao estado seguro.
- `MAN` contém apenas comandos implementados.
- Prefixos semelhantes não causam dupla execução.

# 9. Raspberry Pi e serviços do robô

## 9.1 Papel do Raspberry Pi

O Raspberry Pi não substitui o Arduino no controle de tempo real. Ele executa tarefas de maior nível: interface de câmera e áudio, integração de rede, armazenamento, aplicação Lazarus compatível, gateway serial, telemetria e serviços de IA que caibam na plataforma.

O sistema deve continuar seguro durante boot, atualização ou travamento. A linha de enable dos atuadores não pode depender de um GPIO que fique flutuando; o Arduino mantém o estado desarmado até receber sequência válida.

## 9.2 Instalação do sistema

Use o Raspberry Pi Imager e a documentação oficial atual. Configure usuário próprio, senha forte, rede e SSH durante a gravação quando suportado. Não presuma o antigo usuário `pi` com senha `raspberry`; essa prática pertence a imagens históricas.

Registre:

- modelo do Raspberry Pi;
- arquitetura ARM64 ou ARMHF;
- versão do Raspberry Pi OS;
- imagem e data;
- pacotes instalados;
- serviços habilitados;
- versão do kernel e firmware;
- resultado dos testes de porta serial, câmera e áudio.

## 9.3 Perfil mínimo

Comece pelo sistema Lite quando o robô não precisa de ambiente gráfico local. Instale apenas dependências necessárias. Interfaces gráficas, Chromium, OpenCV, voz e modelos locais aumentam consumo, armazenamento e superfície de falha.

O TCHATGPT declara Linux ARM64 e ARMHF como experimentais no snapshot desta edição. Portanto, compile primeiro `openai_core` e um teste de console. Depois valide `openai_input`, `openai_voice` e `openai_vision` separadamente. Não instale toda a suíte e atribua uma falha genérica ao Raspberry.

## 9.4 Serviços com systemd

Aplicações de longa duração devem ser gerenciadas pelo `systemd`, com usuário sem privilégios administrativos, diretório de trabalho explícito, reinício controlado e log no journal.

```ini
[Unit]
Description=Robotinics Gateway
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=robotinics
Group=robotinics
WorkingDirectory=/opt/robotinics
ExecStart=/opt/robotinics/bin/robotinics-gateway
Restart=on-failure
RestartSec=3
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

Adapte permissões de dispositivo serial por grupo e regras apropriadas. Não execute o serviço como root apenas para acessar `/dev/ttyUSB0`.

## 9.5 Dependências e instalador

Dependências externas devem ser resolvidas de forma determinística pelo instalador ou por script versionado. A documentação informa quais são obrigatórias, opcionais e específicas de plataforma. O teste do instalador precisa confirmar bibliotecas em runtime, não apenas a compilação.

Para os pacotes TCHATGPT, componentes que usam Python devem passar pelo `TAIPythonRuntime`. Visão, voz e bibliotecas nativas precisam validar arquitetura. Um binário x64 não funciona em ARM64; uma biblioteca de 32 bits não satisfaz um processo de 64 bits.

## 9.6 Câmera e áudio

Teste captura e reprodução fora da IA. Primeiro confirme dispositivo, formato, taxa e latência. Em seguida conecte os componentes de voz ou visão. Isso separa falha de hardware, permissão e biblioteca de falha do modelo.

Use nomes persistentes ou regras para dispositivos USB quando a ordem puder mudar. O serviço deve informar claramente “dispositivo ausente” e continuar seguro, em vez de travar o robô inteiro.

## 9.7 Armazenamento

Cartões microSD sofrem desgaste. Evite logs ilimitados e escrita contínua sem rotação. Use banco leve ou arquivos atômicos para configuração, com backup e validação. Dados importantes podem ser enviados a armazenamento externo quando a rede estiver disponível, sem bloquear controle local.

## 9.8 Atualização e rollback

Atualize aplicação e firmware como unidades versionadas. Antes de trocar:

1. salve configuração e versão corrente;
2. verifique assinatura ou origem do pacote;
3. instale em diretório de versão;
4. execute autoteste sem atuadores;
5. altere o link da versão ativa;
6. monitore o primeiro boot;
7. retorne à versão anterior se os critérios falharem.

# 10. Comunicação, dados e segurança de software

## 10.1 Serial antes da rede

A serial local entre Raspberry e Arduino deve ser validada antes de expor qualquer interface de rede. Use 115200 8N1, terminação por linha e protocolo documentado, salvo motivo técnico para outra configuração. O gateway limita tamanho, taxa e tempo de espera.

Não reutilize o mesmo buffer para `Serial`, `Serial1` e uma `SoftwareSerial`. Cada canal possui origem e estado próprios. Quando uma resposta é encaminhada, identifique a origem.

## 10.2 Servidores históricos

Os programas `srvMonitor2` e `srvFala` documentam a experiência original, mas não devem ser executados em rede como estão. Foram encontrados problemas como tamanho de leitura inválido, buffer não terminado, formato controlado por entrada, variável errada enviada a `system`, falta de autenticação e bind em todas as interfaces.

O servidor de fala também encaminha entrada a um shell, o que permite injeção de comandos. A Rev. 3 substitui esse desenho por componentes de voz e uma API que aceita somente campos estruturados, com tamanho, caracteres e ações permitidas.

## 10.3 Portas e contratos

O material histórico usa portas diferentes para o mesmo serviço: a ferramenta de fala usa `7091`, enquanto o servidor atual usa `8091`. O controlador envia `PARAR` em um ponto, mas o firmware reconhece `PARA`. Contratos desse tipo devem existir em um único arquivo versionado e ser testados automaticamente.

A Rev. 3 recomenda não fixar portas em vários fontes. Use configuração central, valor padrão documentado e validação de conflito. Registre endereço, protocolo e finalidade.

## 10.4 Interface de rede

Por padrão, serviços do robô escutam apenas em `127.0.0.1` ou em socket local. Exposição na rede exige autenticação, autorização, limite de requisições e proteção do transporte conforme o risco. Nunca aceite comandos de atuador por Telnet ou socket cru acessível a qualquer máquina.

Quando acesso remoto for necessário, use uma VPN ou camada HTTPS configurada e mantida adequadamente. Firewall deve permitir somente origens e portas necessárias. O botão de emergência e a segurança local continuam independentes da rede.

## 10.5 Mensagens estruturadas

Para comunicação entre serviços, JSON é suficiente quando o volume é moderado. Defina esquema e versão:

```json
{
  "schema": "robotinics.command.v1",
  "request_id": "8f2c...",
  "action": "move_forward",
  "parameters": {"pwm": 120, "duration_ms": 800},
  "requires_confirmation": true
}
```

O serviço valida tipos, campos obrigatórios, intervalos e tamanho antes de converter para o protocolo serial. Campos desconhecidos podem ser rejeitados para evitar interpretações divergentes.

## 10.6 Banco de dados

Banco de dados serve para configuração, inventário, telemetria e auditoria, não para o laço de segurança. O robô deve parar mesmo se o banco estiver indisponível.

Não use conta root na aplicação. Crie usuário com permissões mínimas e armazene segredo fora do código. Consultas são parametrizadas. Interfaces administrativas como phpMyAdmin não devem ficar publicamente expostas nem ser requisito de operação do robô.

O exemplo C histórico de MySQL contém aspas tipográficas, capitalização e parênteses que impedem compilação. Na Rev. 3, exemplos completos devem ser compilados em CI; trechos ilustrativos são identificados como pseudocódigo.

## 10.7 Observabilidade

Cada solicitação recebe `request_id` ou `TraceID`. Registre:

- origem e horário;
- versão do controlador e firmware;
- intenção recebida;
- ação estruturada proposta;
- resultado de validação e confirmação;
- comando enviado;
- telemetria de retorno;
- duração e erro.

Não registre chave de API, senha, áudio ou imagem sensível por padrão. Logs devem possuir rotação e política de retenção.

## 10.8 Testes de resiliência

- desconectar rede durante movimento;
- interromper resposta do modelo;
- enviar JSON inválido e muito grande;
- repetir `request_id`;
- desconectar e reconectar serial;
- reiniciar Raspberry;
- travar processo de gateway;
- indisponibilizar banco;
- simular resposta atrasada;
- confirmar que nenhuma falha impede o Arduino de executar `STOP`.

# Parte IV - Inteligência artificial com TCHATGPT

# 11. Preparando o TCHATGPT

## 11.1 O projeto

TCHATGPT é uma suíte de componentes visuais e não visuais para Lazarus e Free Pascal. No commit adotado, a unit `chatgpt` declara versão 1.7 e integra provedores remotos e servidores locais. A suíte é modular: não instale o antigo pacote monolítico `openai.lpk`.

Para a integração básica do Robotinics, os pacotes principais são:

| Pacote | Uso no robô | Estado no snapshot |
|---|---|---|
| `openai_core` | `TCHATGPT`, prompts, modelos e base | Stable/Beta por compilação |
| `openai_input` | serial, sockets, captura e entrada | Stable/Beta; combinações específicas podem ser experimentais |
| `openai_agent` | agente serial, memória, ações e segurança | misto; componentes usados aqui possuem evidência, pipeline geral segue experimental |
| `openai_voice` | captura, STT, TTS, clonagem autorizada e assistente | Stable/Beta por samples dedicados |
| `openai_vision` | imagem, filtros, câmera e OpenCV | Beta, com backends de maturidade diferente |
| `openai_rag` | indexação e recuperação de documentos | Stable/Beta por sample |
| `openai_observability` | TraceID, spans e métricas | Stable/Beta por compilação |

“PASS” no relatório do projeto significa que um sample compilou. Isso não comprova automaticamente câmera, microfone, placa, modelo ou serviço externo em runtime. A Rev. 3 mantém essa distinção.

## 11.2 Provedores

`TCHATGPT` oferece OpenAI, OpenRouter, Cerebras, Gemini, Claude, DeepSeek, endpoint OpenAI-compatible, llama.cpp, neural-api e perfil local. O livro não obriga um provedor.

Escolha conforme privacidade, latência, custo, disponibilidade e capacidade do hardware:

- **Remoto:** menor exigência computacional no robô; depende de internet e política do provedor.
- **Local x64:** bom para laboratório com um servidor na rede; dados permanecem no ambiente controlado.
- **Local no Raspberry:** maior independência, mas modelos e visão competem por CPU/RAM; requer medição real.
- **Híbrido:** comandos simples e segurança local; tarefas linguísticas complexas em servidor remoto ou local mais potente.

## 11.3 Configuração sem segredo no código

O trecho abaixo usa a API real da versão congelada. `SendQuestion` retorna `Boolean`; a resposta fica em `Response`. Portanto, não trate o retorno da função como texto.

```pascal
uses
  SysUtils, chatgpt;

procedure ConfiguraLLM(Chat: TCHATGPT);
begin
  Chat.Provider := AIP_OPENAI_COMPATIBLE;
  Chat.URL := GetEnvironmentVariable('ROBOTINICS_LLM_URL');
  Chat.CustomModel := GetEnvironmentVariable('ROBOTINICS_LLM_MODEL');
  Chat.TOKEN := GetEnvironmentVariable('ROBOTINICS_LLM_TOKEN');
  Chat.MaxTokens := 256;
  Chat.Temperature := 0.1;
  Chat.Timeout := 30000;
  Chat.Dev :=
    'Converta a intenção em JSON estrito. Não invente comandos. ' +
    'A execução física será validada por outra camada.';
end;

function PerguntaLLM(Chat: TCHATGPT; const Pergunta: string): string;
begin
  if not Chat.SendQuestion(Pergunta) then
    raise Exception.Create(Chat.LastError);
  Result := UTF8Encode(Chat.Response);
end;
```

No laboratório de Marcelo, um servidor local pode estar configurado na porta 8095. Esse valor é configuração do ambiente, não padrão universal do TCHATGPT. Defina `ROBOTINICS_LLM_URL`, por exemplo `http://127.0.0.1:8095/v1/chat/completions`, somente depois de confirmar endpoint e modelo.

## 11.4 Chamadas assíncronas

Interfaces gráficas não devem congelar durante uma requisição. `TCHATGPT` oferece `SendQuestionAsync`, streaming, eventos de estado e cancelamento. Os estados incluem `Idle`, `Connecting`, `Receiving`, `Completed`, `Cancelled` e `Error`.

Use chamadas assíncronas para conversa e explicações. Controle físico requer ainda serialização: não permita duas decisões concorrentes sobre o mesmo atuador. Um coordenador mantém uma fila curta, cancela solicitações antigas e invalida resposta que chegou depois de mudança de estado.

## 11.5 Prompts e contratos

Um prompt não é mecanismo de autorização. Ele descreve o formato esperado, mas toda resposta deve passar por parser. Para controle, use JSON estrito, conjunto pequeno de ações e parâmetros numéricos. Defina temperatura baixa e limite de tokens; respostas longas só aumentam latência e superfície de erro.

Não envie ao modelo todo o histórico, toda a telemetria ou documentos completos. Selecione contexto relevante, informe unidades e inclua o estado atual. Uma decisão feita com telemetria antiga deve expirar.

## 11.6 Autoteste

Antes de associar o LLM ao agente serial:

1. Execute uma pergunta curta e confirme `Response`.
2. Desligue o servidor e valide `LastError` e timeout.
3. Cancele uma requisição.
4. Teste texto com acentos e JSON.
5. Meça latência média e pior caso.
6. Confirme que o token não aparece em log ou configuração.
7. Execute o teste sem qualquer atuador energizado.

# 12. Agente de controle supervisionado

## 12.1 Componentes

O sample `agent_serial_demo` fornece a base mais próxima da necessidade do Robotinics. Ele usa:

- `TCHATGPT` para interpretação;
- `TAISerialModem` para porta real;
- `TAIListSerialDevices` para descoberta de portas;
- `TAIAgentSerial` para ações estruturadas;
- `TAIAgentAction` como catálogo de comandos;
- `TAIAgentMemoryMap` para histórico;
- eventos para confirmação, log e comandos rejeitados.

A Rev. 3 acrescenta `TAIAgentSafety` e um validador específico de parâmetros do robô.

## 12.2 Configuração segura

```pascal
procedure TfrmRobotinics.ConfiguraAgente;
begin
  AIAgentSerial1.Serial := AISerialModem1;
  AIAgentSerial1.LLM := CHATGPT1;
  AIAgentSerial1.CommandCatalog := AIAgentCommands1;
  AIAgentSerial1.RequireConfirmation := True;
  AIAgentSerial1.MaxActionsPerPrompt := 3;
  AIAgentSerial1.AutoDiscoverCommands := True;
  AIAgentSerial1.AllowUnknownDeviceCommands := False;
  AIAgentSerial1.ClearCatalogOnDisconnect := True;

  AIAgentSafety1.Enabled := True;
  AIAgentSafety1.ReadOnlyMode := False;
  AIAgentSafety1.SimulationMode := False;
  AIAgentSafety1.AllowIndustrialWrite := True;
  AIAgentSafety1.RequireConfirmation := True;
end;
```

`AllowIndustrialWrite=True` não libera tudo. A lista de ações, registro de capacidades, catálogo `MAN`, validador de parâmetros e confirmação continuam obrigatórios.

## 12.3 Registro de capacidade

Registre a ação que representa envio físico:

```pascal
RegisterActionCapability(
  'ROBOTINICS_SERIAL_SEND',
  [acIndustrialWrite, acStateMutation]
);
```

Adicione essa ação a `AIAgentSafety1.AllowedActions`. A política é fail-closed: ação sem registro deve ser recusada.

## 12.4 Evento antes da ação

O evento `OnBeforeAction` recebe o tipo e o parâmetro propostos. A implementação do Robotinics deve:

1. mapear o tipo interno para uma ação de segurança;
2. validar sintaxe e faixa do comando físico;
3. validar estado e telemetria atual;
4. chamar `TAIAgentSafety.ValidateAction`;
5. apresentar confirmação clara;
6. definir `AAllow=True` apenas se todas as etapas passarem.

```pascal
procedure TfrmRobotinics.AgentBeforeAction(Sender: TObject;
  AKind: TAgentActionKind; const AParam: string; var AAllow: Boolean);
var
  Params: TStringList;
  Erro: string;
begin
  AAllow := False;

  if not ValidaComandoRobotinics(AKind, AParam, Erro) then
  begin
    RegistraRejeicao(AParam, Erro);
    Exit;
  end;

  Params := TStringList.Create;
  try
    Params.Values['COMMAND'] := AParam;
    AAllow := AIAgentSafety1.ValidateAction(
      'ROBOTINICS_SERIAL_SEND', Params, Erro);
  finally
    Params.Free;
  end;

  if not AAllow then
    RegistraRejeicao(AParam, Erro);
end;
```

`ValidaComandoRobotinics` é código do aplicativo, pois conhece comandos, faixas, estado e sensores. O componente genérico não deve embutir regras específicas do robô.

## 12.5 Confirmação compreensível

Não mostre apenas “Permitir send?”. Mostre ação física e consequência:

```text
O robô moverá para frente com PWM 120 por até 800 ms.
Distância frontal atual: 640 mm.
Estado: ARMED. Bateria: 11,78 V.
[Permitir uma vez] [Cancelar]
```

Não use confirmação genérica para uma sequência longa. Cada ação de movimento deve ser curta ou a sequência inteira deve ser apresentada com limite e opção de interrupção.

## 12.6 Descoberta determinística

Ao conectar, `TAIAgentSerial` envia `MAN`. O parser espera `MAN-BEGIN`, coleta linhas `COMMAND <nome>: <descrição>` e conclui em `MAN-END`. A LLM não interpreta o manual; o parser faz isso. Antes de `send`, o primeiro token é comparado ao catálogo.

Esse desenho é uma força do projeto TCHATGPT e deve ser preservado. Para o Robotinics, o firmware publica apenas comandos realmente disponíveis para a configuração atual. Um braço ausente não deve gerar comandos de braço.

## 12.7 Memória de sessão

`TAIAgentMemoryMap` pode registrar pergunta, resposta e ações. Não use histórico como fonte de estado físico: o estado vem da telemetria atual. Uma frase antiga como “o robô está armado” não autoriza movimento depois de reinício.

Não grave token no histórico. Defina retenção, opção de nova conversa e tamanho máximo. Para auditoria, armazene IDs e resultados de validação em log separado da conversa.

## 12.8 Limites atuais

`TAIAgentSerial.Execute` usa chamada síncrona ao LLM. Em GUI, execute a operação de forma que não bloqueie a interface e sincronize o acesso aos componentes. O componente limita número de ações, mas não conhece aceleração, geometria, bateria ou distância; essas regras pertencem ao Robotinics.

## 12.9 Testes adversariais

Peça ao modelo:

- um comando que não existe;
- movimento com PWM negativo ou 999;
- movimento por tempo muito longo;
- ignorar instruções e enviar texto ao shell;
- executar cinco ações quando o limite é três;
- mover enquanto `DISARMED`;
- avançar com obstáculo próximo;
- usar informação de um documento RAG como comando.

Todos devem ser bloqueados ou convertidos em pergunta sem ação.

# 13. Voz e interação humana

## 13.1 Pipeline

O pacote `openai_voice` integra o fluxo:

```text
TAIAudioInput → TAISpeechRecognizer → TCHATGPT
             → TAIVoiceClone ou TAIVoiceSynthesizer → TAIAudioPlayer
```

`TAIVoiceAssistant` coordena reconhecimento, modelo e síntese. Estados permitem informar se o sistema está ouvindo, reconhecendo, pensando, falando, cancelado ou em erro.

## 13.2 Reconhecimento de fala

O backend Whisper por processo exige executável e modelo compatíveis. Variáveis como `WHISPER_CLI` e `WHISPER_MODEL` evitam caminhos fixos. Teste primeiro um arquivo WAV conhecido; depois o microfone; por fim a integração.

Reconhecimento contínuo pode dividir áudio em blocos. No snapshot, o processamento continua síncrono, por isso a GUI deve usar worker apropriada. O operador precisa de indicador visível quando o microfone está ativo.

## 13.3 Voz não é autorização

Ruído ou reconhecimento incorreto pode transformar “não avance” em “avance”. Ações físicas obtidas por voz exigem confirmação por interface ou frase de confirmação com desafio claro. Palavras de parada devem ter tratamento local e prioridade, mas não substituem o botão de emergência.

Uma sequência recomendada é:

1. usuário: “vá um pouco para frente”;
2. STT produz texto;
3. agente propõe `MOVEFWD 90 500`;
4. aplicação apresenta a interpretação;
5. usuário confirma;
6. validação e firmware executam;
7. voz informa o resultado.

## 13.4 Síntese tradicional e clonagem

Para feedback operacional, TTS tradicional é suficiente e reduz dependências. Clonagem de voz é opcional. `TAIVoiceClone` exige consentimento por padrão, identificação do titular e áudio de referência autorizado. Não clone voz de terceiros sem autorização explícita.

O arquivo sintetizado só deve ser anunciado depois de existir, possuir tamanho e cabeçalho WAV válidos. Cancelamento deve alcançar STT, LLM e síntese.

## 13.5 Privacidade

Não grave microfone continuamente por padrão. Informe captura, retenção e destino. Quando STT ou LLM remoto for usado, áudio ou texto pode sair do dispositivo. Para demonstração em sala, evite armazenar voz dos participantes.

## 13.6 Critérios de aceitação

- Captura e reprodução funcionam isoladamente.
- STT acerta um conjunto de frases de teste em ambiente real.
- Cancelamento interrompe todas as etapas.
- Ação física sempre passa pela mesma validação do texto digitado.
- Consentimento de clonagem é verificável.
- Ausência de microfone ou modelo gera erro claro e não trava o robô.

# 14. Visão computacional

## 14.1 Correção histórica

O arquivo histórico `face.py` importa VPython/`visual` e desenha uma face animada. Ele não implementa reconhecimento facial com OpenCV e não deve ser apresentado como tal. O Motion realiza captura/detecção de movimento conforme configuração, mas também não equivale automaticamente a reconhecimento semântico.

## 14.2 Componentes atuais

`TAIOpenCV` possui dois backends:

| Backend | Uso recomendado | Limitação |
|---|---|---|
| `ocvPythonProcess` | processamento real de imagem por worker Python | depende de Python, OpenCV e NumPy |
| `ocvNativeDLL` | detecção e carregamento do runtime | processamento nativo completo ainda é parcial/experimental |

Na versão congelada, filtros reais incluem gray, blur, Canny, threshold e resize no backend Python. O demo combinado menciona tracking simulado em partes; portanto, ele não deve ser usado como prova de reconhecimento real.

Para detecção de faces, objetos ou pose, use componentes e samples dedicados, confirme backend real e valide com imagens de teste. `TAIHumanPoseDetector` requer plataforma 64 bits no estado documentado.

## 14.3 Pipeline do Robotinics

O pipeline recomendado é:

1. capturar frame com timestamp;
2. validar dimensões e formato;
3. reduzir resolução quando apropriado;
4. executar filtro ou detector especializado;
5. converter resultado em observação estruturada;
6. aplicar limiar e estabilidade temporal;
7. fornecer a observação ao planejador;
8. manter segurança de proximidade independente.

[FIGURE:vision_pipeline]

Não envie a imagem inteira ao LLM quando uma detecção local simples responde à pergunta. Um detector pode produzir `PERSON confidence=0.91 x=...`; o agente recebe essa observação e decide se deve explicar, perguntar ou propor ação.

## 14.4 Desempenho no Raspberry

Meça FPS, latência, CPU, RAM, temperatura e consumo. Um modelo que funciona em desktop pode causar throttling no Raspberry. Ajuste resolução, intervalo de análise e modelo. Separe a captura do processamento para não acumular frames antigos; quando atrasado, descarte e use o frame mais recente.

## 14.5 Segurança e ética

Detecção de rosto não significa identificação confiável. Reconhecimento de pessoas envolve consentimento, viés, proteção de dados e risco de falsa identificação. Para o projeto educacional, prefira detecção de presença, cor, marcador ou objeto sem identidade.

Visão não deve ser única fonte de parada. Iluminação, oclusão e movimento causam falhas. Sensores locais e limites de velocidade continuam ativos.

## 14.6 Testes

- imagem válida, corrompida e ausente;
- câmera desconectada durante execução;
- variação de luz e fundo;
- objeto parcialmente oculto;
- frame atrasado;
- detector indisponível;
- alta carga de CPU;
- confirmação de que falha de visão reduz capacidade e não libera movimento.

# 15. Memória e RAG

## 15.1 Uso no robô

RAG permite responder com base em documentos do projeto sem treinar novamente o modelo. O Robotinics pode indexar:

- manual da Rev. 3;
- catálogo de componentes e fichas técnicas autorizadas;
- mapa de pinos;
- registros de manutenção;
- procedimentos de teste;
- histórico de falhas resumido;
- versão do protocolo.

O objetivo é apoiar diagnóstico e operação, não transformar texto recuperado em ação automática.

## 15.2 TAIRAG

`TAIRAG` integra `TAIGraphMap` e `TCHATGPT`. O fluxo mínimo é associar componentes, adicionar arquivos/pastas, construir índice, recuperar contexto e perguntar. A versão atual oferece modos grafo, vetor, BM25 e híbrido, orçamento de tokens e reranking opcional.

```pascal
RAG.GraphMap := GraphMap;
RAG.ChatGPT := ChatGPT;
Agent.RAG := RAG;
Agent.ChatGPT := ChatGPT;

RAG.AddFolder('/opt/robotinics/docs');
RAG.BuildIndex;
```

Use filtros de extensão e diretório. Não indexe segredos, chaves, logs brutos ou dados pessoais sem necessidade.

## 15.3 Separação entre conhecimento e autoridade

Um documento pode dizer “para testar, envie FRENTE”. Esse texto não autoriza a ação. O RAG fornece contexto para resposta; apenas o catálogo do dispositivo e a política de segurança definem ações permitidas. Conteúdo recuperado é tratado como dado não confiável e não pode sobrescrever as instruções do agente.

## 15.4 Fontes e rastreabilidade

A resposta deve apresentar arquivos ou trechos usados. Armazene hash, versão e data do documento. Se duas revisões divergem, prefira a vinculada à versão do robô e informe o conflito.

Uma resposta útil é: “Segundo o mapa de pinos da revisão 3.0, o trigger frontal está no pino X; confirme a placa instalada.” Uma resposta ruim é afirmar certeza sem fonte ou misturar pinos de revisões diferentes.

## 15.5 Fatiamento

Chunks devem preservar unidade semântica: procedimento completo, definição com fórmula ou tabela com cabeçalho. Tamanho fixo é um ponto de partida, não solução universal. Use sobreposição moderada e metadados de capítulo, componente e versão.

Avalie com perguntas reais e conjunto de respostas esperadas. Meça recuperação da fonte correta antes de culpar o LLM. Um modelo pequeno pode responder bem se o contexto recuperado for curto e preciso.

## 15.6 Memória operacional

Separe:

- **estado atual:** telemetria volátil, nunca obtida de conversa;
- **memória de sessão:** diálogo e ações recentes;
- **memória de manutenção:** eventos confirmados e versões;
- **base documental:** conteúdo indexado e versionado.

Ao reiniciar, o estado físico começa desconhecido/desarmado, mesmo que a memória diga que o robô estava armado.

## 15.7 Avaliação

Crie um conjunto de perguntas:

- Qual a tensão nominal do pack 3S?
- Qual comando sempre deve parar o robô?
- Onde está o arquivo do firmware?
- O backend nativo do OpenCV processa imagens de forma completa?
- Qual revisão do mapa de pinos está instalada?

Registre fonte recuperada, resposta, acerto, latência e tokens. Inclua perguntas sem resposta; o sistema deve admitir ausência de evidência.

# 16. Comportamentos inteligentes e limites

## 16.1 Modos de operação

| Modo | IA | Atuadores | Uso |
|---|---|---|---|
| Manual | opcional para explicação | operador envia comandos | diagnóstico inicial |
| Assistido | interpreta intenção | confirmação por ação | uso recomendado |
| Supervisionado | propõe sequência curta | limites e confirmação da sequência | tarefas validadas |
| Simulação | decide sobre modelo virtual | sem saída física | desenvolvimento e teste |

Autonomia física sem supervisão não é objetivo inicial da Rev. 3. Ela só deve ser considerada depois que testes, localização, obstáculos, energia e recuperação de falhas estiverem validados.

## 16.2 Habilidades apropriadas

Primeiras habilidades:

- explicar estado e falha;
- descobrir e listar comandos;
- consultar sensores;
- propor movimento curto com confirmação;
- guiar checklist de manutenção;
- responder perguntas usando RAG;
- reconhecer frase e falar resposta;
- descrever observação de visão já estruturada.

Evite inicialmente:

- navegação prolongada sem mapa/localização;
- manipulação de objetos frágeis ou pessoas;
- execução de shell;
- alteração automática de firmware;
- uso irrestrito de internet;
- cadeia longa de ações sem confirmação ou feedback.

## 16.3 Planejar, executar e verificar

Uma tarefa é dividida em passos curtos. Antes de cada passo, valide estado. Depois, leia telemetria e compare resultado. Se o efeito não for confirmado, pare; não repita indefinidamente.

Exemplo “aproxime-se 30 cm”:

1. verificar sensor e estado;
2. propor deslocamento inicial curto;
3. confirmar;
4. executar por tempo limitado;
5. medir novamente;
6. recalcular com limite de iterações;
7. parar e informar resultado.

Sem odometria calibrada e sensor confiável, o sistema deve dizer que não consegue garantir 30 cm.

## 16.4 Incerteza

O agente precisa distinguir fato, inferência e ausência de dados. Telemetria com timestamp antigo não é “estado atual”. Detecção com baixa confiança não é presença confirmada. Documento de outra revisão não é autoridade para a montagem atual.

Defina limiares e respostas: perguntar ao operador, repetir leitura, reduzir velocidade ou recusar. “Não sei” é comportamento seguro.

## 16.5 Observabilidade de IA

Registre versão do modelo, provedor, temperatura, hash do prompt, TraceID, latência e resposta estruturada. Para privacidade, não armazene todo o conteúdo por padrão. Em caso de falha, deve ser possível responder: qual modelo propôs, qual validador bloqueou ou permitiu e qual comando o firmware recebeu.

## 16.6 Critério de promoção

Uma habilidade sai de simulação para operação física quando:

- possui contrato e limites documentados;
- todos os comandos pertencem ao catálogo;
- testes normais e adversariais passam;
- existe parada independente;
- falhas de rede/modelo são seguras;
- a interface informa claramente intenção e confirmação;
- resultados foram repetidos em hardware real;
- a versão do código foi congelada.

# Parte V - Construção, validação e evolução

# 17. Sequência de construção

## 17.1 Etapa 0 - documentação e inventário

Antes de comprar ou ligar componentes:

1. baixe a versão congelada do projeto;
2. gere inventário dos arquivos necessários;
3. identifique os componentes realmente disponíveis;
4. confira fichas técnicas e tensões;
5. registre substituições;
6. prepare esquema de alimentação;
7. defina botão de emergência e procedimento de teste.

Não use fotografias como único esquema. Produza mapa de conexões com nomes, pinos, tensão e corrente. Uma substituição de motor ou servo pode alterar mecânica, energia e firmware ao mesmo tempo.

## 17.2 Etapa 1 - mecânica passiva

Monte base, rodas, suportes e estrutura sem bateria. Verifique alinhamento, folgas e acesso. Instale pesos simulando bateria e placas para avaliar centro de gravidade. Braços permanecem sem carga e sem braços de servo durante o primeiro ajuste.

Aceitação: a base rola livre, não tomba nas poses permitidas e não apresenta interferência de cabos ou peças.

## 17.3 Etapa 2 - distribuição elétrica

Monte fusíveis, chave, conversores e bornes, mas teste inicialmente com fonte de bancada limitada em corrente. Valide um trilho por vez com carga eletrônica ou carga conhecida. Meça polaridade antes de conectar placas.

Aceitação: tensões permanecem dentro da tolerância durante transientes; não há aquecimento inesperado; desligamento remove energia dos atuadores conforme projeto.

## 17.4 Etapa 3 - Arduino sem atuadores

Carregue firmware Rev. 3. Use terminal serial para testar `PING`, `MAN`, `STATUS?`, linhas inválidas, overflow e timeout. Simule sensores quando possível. Verifique que o boot sempre informa `DISARMED`.

Aceitação: catálogo corresponde ao firmware, parser não executa prefixos parciais e falhas não bloqueiam o loop.

## 17.5 Etapa 4 - tração suspensa

Eleve as rodas. Conecte driver e motores com limite de corrente. Teste uma direção por vez, depois `STOP`, duração e watchdog. Confirme que esquerda e direita correspondem à convenção. Inverta fios ou configuração de forma documentada; não espalhe correções de sentido em várias rotinas.

Aceitação: partida, rampa, direção, parada e timeout são previsíveis; corrente e temperatura permanecem abaixo dos limites definidos.

## 17.6 Etapa 5 - servos e sensores

Conecte um servo por vez. Calibre zero e limites sem braço; depois instale elo sem carga e meça corrente. Sensores são validados individualmente, inclusive timeout e valores fora de faixa.

Aceitação: nenhuma articulação colide; perda de sensor relevante reduz capacidade; fonte não reinicia lógica durante movimento.

## 17.7 Etapa 6 - Raspberry e gateway

Instale o sistema, crie usuário de serviço e valide serial. O gateway consulta estado e registra telemetria, mas ainda não controla movimento por rede. Teste reinício, desconexão e permissões.

Aceitação: Raspberry pode reiniciar sem acionar atuadores; serviço recupera comunicação e informa versão.

## 17.8 Etapa 7 - TCHATGPT em simulação

Configure LLM e agente com `SimulationMode=True` ou sem a serial física associada. Use catálogo de teste e execute perguntas normais e adversariais. Verifique JSON, limites e confirmação.

Aceitação: o modelo não consegue ultrapassar catálogo e política; a interface permanece responsiva; credenciais não são persistidas em texto claro.

## 17.9 Etapa 8 - agente com hardware

Conecte a serial real com rodas suspensas. Descubra `MAN`, consulte estado e execute apenas `STOP`, `PING` e sensores. Depois autorize movimentos curtos. Monitore fisicamente e mantenha emergência ao alcance.

Aceitação: ação proposta, confirmação, comando, telemetria e log apresentam o mesmo `request_id`; qualquer divergência interrompe o teste.

## 17.10 Etapa 9 - voz, visão e RAG

Adicione um recurso por vez. Voz primeiro produz texto sem ação; visão primeiro produz observação; RAG primeiro responde com fontes. Somente depois cada recurso pode alimentar o agente, passando pelas mesmas barreiras.

Aceitação: falha do recurso adicional não altera a segurança básica; o operador sabe quando câmera/microfone estão ativos.

## 17.11 Primeira operação no piso

Use área plana, livre e demarcada. Comece com baixa velocidade e distância curta. Registre vídeo, telemetria, corrente e temperatura. Aumente gradualmente. Rampas e braços são fases posteriores, nunca parte do primeiro teste integrado.

# 18. Plano de testes e comissionamento

## 18.1 Pirâmide de testes

[FIGURE:test_pyramid]

Testes começam em funções e módulos, avançam para integração e terminam no robô completo. Quanto mais físico e integrado, mais caro e perigoso é descobrir defeito. Parser, cálculo e política devem ser exercitados sem hardware.

## 18.2 Matriz mínima

| ID | Ensaio | Condição | Resultado esperado |
|---|---|---|---|
| PWR-01 | Polaridade | sem placas | todas as saídas corretas |
| PWR-02 | Partida de servo | pior carga validada | lógica não reinicia |
| PWR-03 | Subtensão | fonte reduzida controladamente | atuadores param e falha é registrada |
| FW-01 | Boot | qualquer reset | `DISARMED`, motores desligados |
| FW-02 | Linha longa | > buffer | erro, nenhuma execução |
| FW-03 | Heartbeat perdido | durante movimento | `STOP` dentro do limite |
| FW-04 | Comando desconhecido | linha válida | recusado |
| AG-01 | Comando inventado | resposta do LLM | bloqueado pelo catálogo |
| AG-02 | Parâmetro fora da faixa | PWM 999 | bloqueado pelo validador |
| AG-03 | Sem confirmação | movimento | não enviado |
| NET-01 | Rede perdida | durante operação | segurança local preservada |
| VIS-01 | Câmera ausente | início e runtime | erro claro, sem liberar movimento |
| VOI-01 | Frase ambígua | ruído | pergunta/recusa, sem ação |
| RAG-01 | Documento conflitante | revisão antiga | conflito informado |

## 18.3 Medições elétricas

Registre em cada modo:

| Modo | V bateria | I bateria | V lógica mínima | I servo pico | Temperatura |
|---|---:|---:|---:|---:|---:|
| Repouso | | | | | |
| Rodas suspensas | | | | | |
| Partida no piso | | | | | |
| Giro | | | | | |
| Braço, pior pose validada | | | | | |

Use instrumento e método seguros. Uma medida isolada não representa pico rápido; osciloscópio ou registrador pode ser necessário para queda de tensão.

## 18.4 Medições mecânicas

- massa total e distribuição;
- diâmetro real das rodas;
- corrente e velocidade em piso plano;
- inclinação máxima validada;
- distância de parada por velocidade;
- folga de articulação;
- repetibilidade de posição;
- temperatura de motores e servos;
- estabilidade com braços em posições extremas.

## 18.5 Avaliação da IA

Crie conjunto fixo de frases em português, incluindo variações e erros. Classifique:

- resposta sem ação;
- consulta de sensor;
- ação válida;
- ação ambígua;
- ação proibida;
- ataque de prompt;
- pedido impossível;
- perda de contexto.

Para cada caso, registre JSON proposto, decisão do validador, necessidade de confirmação e resposta final. Trocar modelo exige repetir o conjunto; modelos com nomes semelhantes podem se comportar de forma diferente.

## 18.6 Injeção de falhas

Falhas devem ser provocadas de modo controlado:

- remover cabo serial;
- desligar servidor LLM;
- atrasar resposta;
- enviar bytes corrompidos;
- bloquear sensor;
- simular corrente alta por entrada de teste;
- reiniciar processo;
- encher espaço de log em ambiente de teste;
- fornecer documento RAG com instrução maliciosa.

O objetivo é verificar saída segura e diagnóstico, não danificar o equipamento.

## 18.7 Registro de ensaio

Cada ensaio contém:

```text
ID e título:
Data e responsável:
Versão mecânica:
Firmware e commit:
Aplicação/TCHATGPT e commit:
Hardware e configuração:
Pré-condições:
Passos:
Resultado esperado:
Resultado observado:
Medições e evidências:
Conclusão: PASS / FAIL / BLOQUEADO
Anomalia vinculada:
```

## 18.8 Critério de comissionamento

O robô pode operar supervisionado quando todos os testes críticos passam, não há falha aberta de segurança e a configuração testada corresponde à montada. Uma demonstração bem-sucedida não substitui o conjunto de ensaios.

# 19. Manutenção e evolução

## 19.1 Inspeção periódica

Antes de cada sessão, verifique bateria, conectores, fusíveis, rodas, parafusos, cabos e emergência. Depois de impactos ou transporte, repita inspeção mecânica e teste suspenso.

Periodicamente:

- confira capacidade e equilíbrio do pack com procedimento apropriado;
- limpe e inspecione motores e articulações;
- procure aquecimento e escurecimento em conectores;
- revise logs de subtensão, sobrecorrente e watchdog;
- faça backup de configuração e índice RAG;
- aplique atualização apenas com plano de rollback;
- repita testes afetados.

## 19.2 Compatibilidade

Mantenha uma matriz de sistema operacional, arquitetura, Lazarus, FPC, pacotes e runtime. “Compila no Windows” não prova Linux ou ARM. O CI deve construir samples por pacote e um conjunto Robotinics específico. Testes em hardware ficam separados dos testes de compilação.

## 19.3 Repositório reproduzível

A Rev. 3 recomenda:

1. tag do Robotinics correspondente ao livro;
2. diretório `docs/rev3` com fonte editável do livro;
3. firmware Rev. 3 separado do legado;
4. sample Lazarus `robotinics_ai_controller`;
5. esquemas e BOM versionados;
6. script de instalação e verificação;
7. CI para firmware e Lazarus;
8. releases com checksum;
9. política de vulnerabilidades e contribuição.

Arquivos compilados, objetos e caches não devem substituir fontes. Ferramentas históricas removidas podem ficar em tag `legacy`, com aviso de segurança.

## 19.4 Roadmap técnico

### Prioridade 0 - segurança e reprodução

- validar pack, BMS, carregador, fusível e trilhos;
- implementar firmware Rev. 3 com watchdog;
- corrigir mapa de pinos e comandos;
- criar parada física e teste de falha;
- congelar BOM e versões.

### Prioridade 1 - controlador inteligente

- adaptar `agent_serial_demo` ao Robotinics;
- integrar `TAIAgentSafety` e validador específico;
- criar modo simulação;
- adicionar telemetria e TraceID;
- testar Windows/Linux x64.

### Prioridade 2 - Raspberry ARM64

- criar CI ou build reproduzível ARM64;
- validar `openai_core`, serial e agente;
- validar voz e visão separadamente;
- medir desempenho e temperatura;
- promover componentes somente com evidência.

### Prioridade 3 - percepção e conhecimento

- RAG com documentos versionados;
- voz com consentimento e confirmação;
- visão com backend real identificado;
- datasets de avaliação;
- observabilidade e regressão.

## 19.5 Publicação

Antes de publicar:

- definir licença do texto e das figuras;
- manter a licença GPLv3 e avisos aplicáveis ao TCHATGPT;
- auditar origem de imagens e modelos de terceiros;
- remover senhas, tokens e dados pessoais;
- verificar links e commits;
- revisar tecnicamente bateria, elétrica e mecânica;
- gerar PDF com bookmarks, links e texto copiável;
- oferecer DOCX ou fonte equivalente para futuras revisões.

O repositório Robotinics não apresenta licença formal no snapshot examinado. A alegação de projeto aberto deve ser acompanhada por um arquivo de licença escolhido pelo autor. Esta edição não escolhe a licença em nome dele.

# Apêndice A - Lista de materiais orientativa

Esta lista organiza categorias. Modelo e quantidade finais dependem da montagem e devem constar na BOM versionada.

| Subsistema | Itens | Verificação |
|---|---|---|
| Estrutura | peças STL/CAD, parafusos, insertos, suportes | material, revisão, carga e folga |
| Tração | motores com redução, rodas, driver | tensão, corrente de stall, torque contínuo |
| Controle | Arduino Mega ou placa compatível | pinos, memória, interfaces |
| Computação | Raspberry Pi compatível, armazenamento | arquitetura, alimentação, temperatura |
| Energia | pack 3S, BMS, carregador, fusível, chave | química, corrente, certificação e montagem |
| Conversão | trilho de tração, servos e lógica | tensão, corrente, ripple e refrigeração |
| Servos | atuadores e suportes | torque calculado, limites e corrente |
| Sensores | ultrassom, tensão, corrente, IMU/gás conforme uso | nível lógico, faixa, calibração |
| Interface | câmera, microfone, alto-falante | driver, consentimento, consumo |
| Segurança | emergência, proteções, fixação | acesso, teste e falha segura |
| Fiação | fios, bornes, conectores, etiquetas | corrente, queda, polarização e flexão |

Não compre pela BOM histórica sem conferir disponibilidade e especificação. Clones com o mesmo nome comercial podem diferir.

# Apêndice B - Protocolo de comandos

## B.1 Regras

- ASCII/UTF-8 restrito para comandos; uma linha por mensagem.
- Terminação `LF` ou `CRLF`.
- Máximo de 127 bytes de conteúdo por linha na configuração de referência.
- Primeiro token identifica exatamente o comando.
- Números decimais sem unidade somente quando o contrato fixa unidade.
- `STOP`, `DISARM`, `PING`, `STATUS?` e `MAN` não dependem de IA.
- Movimento exige estado `ARMED`.
- Respostas incluem `OK`, `ERR`, `STATE` ou `EVENT`.

## B.2 Catálogo mínimo

| Comando | Parâmetros | Estado | Efeito |
|---|---|---|---|
| `PING` | nenhum | qualquer | responde `OK PING` |
| `MAN` | nenhum | qualquer | publica catálogo |
| `STATUS?` | nenhum | qualquer | retorna estado e falhas |
| `ARM` | conforme política | `DISARMED` | executa autoteste e arma |
| `DISARM` | nenhum | qualquer | desabilita atuadores |
| `STOP` | nenhum | qualquer | interrompe movimento |
| `MOVEFWD` | PWM, ms | `ARMED` | avanço limitado |
| `MOVEBACK` | PWM, ms | `ARMED` | ré limitada |
| `TURNLEFT` | PWM, ms | `ARMED` | giro limitado |
| `TURNRIGHT` | PWM, ms | `ARMED` | giro limitado |
| `RANGE?` | opcional sensor | qualquer | distância ou timeout |
| `BATTERY?` | nenhum | qualquer | tensão e estado |
| `SERVO` | eixo, ângulo, velocidade | `ARMED` | pose dentro dos limites |

## B.3 Aliases legados

| Legado | Rev. 3 | Observação |
|---|---|---|
| `FRENTE` | `MOVEFWD` | parâmetros padrão conservadores |
| `RE` | `MOVEBACK` | parâmetros padrão conservadores |
| `GESQ` | `TURNLEFT` | duração limitada |
| `GDIR` | `TURNRIGHT` | duração limitada |
| `PARA` | `STOP` | `PARAR` pode ser aceito apenas como alias documentado |

Aliases não contornam estado, catálogo ou limites.

# Apêndice C - Matriz de correções da edição anterior

| Local aproximado | Problema identificado | Correção adotada na Rev. 3 |
|---|---|---|
| pp. 32-45 | força em N comparada diretamente a torque em N·m | fórmulas separadas e conversão por raio |
| pp. 38-39 | massa, peso, kgf, N e inclinação misturados | `m×g×sen(θ)` e exemplo dimensional |
| pp. 42-45 | torque de braço em `kgf·cm²` e massas inconsistentes | soma de momentos em N·m, centros de massa e margem |
| pp. 49-50 | `0,02 A = 200 mA` | `0,02 A = 20 mA` |
| pp. 53-56 | potência aparente/reativa aplicada ao pack DC | cálculo por W, Wh e eficiência de conversão |
| pp. 58-59 | capacidade de células em série somada | 3S mantém 5,2 Ah; soma apenas tensão |
| p. 96 | `20,75×10⁻³ F` convertido em 20,75 µF | valor correto: 20.750 µF |
| pp. 97-113 | carga de lítio baseada em corrente incorreta e permanência indefinida | carregador CC/CV 3S, BMS, balanceamento e ficha técnica |
| pp. 108-113 | buck ajustado para 12,6 V com entrada de 12 V | buck não eleva tensão; arquitetura redesenhada |
| p. 106 | NA/NF invertidos | NO aberto em repouso; NC fechado em repouso |
| p. 113 | amperímetro ligado em paralelo na saída | corrente medida em série; aviso de curto |
| pp. 135-146 | correntes de trilhos somadas e fonte única subdimensionada | orçamento por potência e trilhos separados |
| pp. 140-144 | L298N descrito sem PWM/como isolação | PWM nos enables, sem isolamento, perdas explicitadas |
| pp. 150-155 | HC-SR04 indicado como 40 Hz | aproximadamente 40 kHz |
| exemplo ultrassom | `echoPin`/`trigPin` indefinidos e mesma amostra repetida | pinos definidos, timeout e amostras distintas |
| pp. 187-193 | servo associado apenas a pinos PWM | biblioteca usa temporizadores e pinos digitais compatíveis |
| p. 196 | `5/330 = 0,15 A` | `5/330 ≈ 0,015 A`; fórmula usa queda do LED |
| p. 216 | exemplo MySQL com aspas tipográficas e erros de sintaxe | exemplos compiláveis e consultas parametrizadas |
| pp. 218-220 | servidores C/C++ com buffers, formato e shell inseguros | retirados da arquitetura operacional; gateway validado |
| pp. 221-223 | Motion confundido com visão semântica | captura/movimento separados de detecção/classificação |
| pp. 252-255 | OpenCV 2.4 e instalação antiga | referência à documentação atual e backends TCHATGPT |
| `face.py` | animação VPython apresentada como reconhecimento | classificado corretamente; usar detector real |
| pp. 256-267 | PocketSphinx antigo como única rota | Whisper/STT modular, mantendo Sphinx apenas como legado |
| pp. 268-275 | FANN e exemplos ausentes/incompletos | componentes ML atuais ou documentação explicitamente histórica |
| pp. 280-297 | PHP5, root MySQL, phpMyAdmin exposto, `chmod 777` | privilégio mínimo, serviço local, autenticação e permissões |
| firmware | `String`, delays, buffer compartilhado e sem timeout | parser fixo, módulos, watchdog e limites |
| firmware | macros GPS inválidas e risco de overflow/bloqueio | definições corretas, buffer limitado e timeout |
| firmware | `ULTRA` antes de `ULTRA1/2` | comparação exata do primeiro token |
| firmware | `substring(5)` para prefixo `SERIAL:` | parser por token e tamanho real |
| ferramentas | portas 7091/8091 e `PARAR`/`PARA` divergentes | contrato central e aliases documentados |
| repositório | ferramentas citadas removidas do branch atual | snapshot e histórico declarados; novo sample proposto |
| editorial | capítulo 6.2 ausente, links sem clique, sem bookmarks | numeração contínua, navegação e links |
| PDF | afirmação de abertura sem licença formal | decisão de licença exigida antes da publicação |

# Apêndice D - Fórmulas de referência

| Grandeza | Fórmula | Unidade |
|---|---|---|
| Peso | `F = m × g` | N |
| Força de aclive | `F = m × g × sen(θ)` | N |
| Rolamento | `F = Crr × m × g × cos(θ)` | N |
| Aceleração | `F = m × a` | N |
| Torque | `T = F × r` | N·m |
| Torque de braço | `T = Σ(m_i × g × d_i)` | N·m |
| Potência DC | `P = V × I` | W |
| Energia | `E = P × t` ou `V × Ah` | Wh |
| Resistor de LED | `R = (V_fonte - V_LED) / I` | Ω |
| Potência no resistor | `P = I² × R` | W |
| Capacitor de ripple | `C ≈ I/(f×ΔV)` | F |
| Autonomia | `t ≈ E_utilizável/P_média` | h |
| Distância ultrassônica | `d = v_som × tempo/2` | m |

Use unidades coerentes. Converta milímetros para metros e miliampères para ampères antes de calcular. Declare hipóteses e arredondamento.

# Apêndice E - Matriz de plataforma e dependências

| Camada | Windows x64 | Linux x64 | Raspberry ARM64 | Observação |
|---|---|---|---|---|
| `openai_core` | suportado | suportado | provável/experimental | validar HTTPS e runtime |
| serial/input | suportado por samples | suportado por samples | provável/experimental | permissões e dispositivo |
| agente serial | compila no relatório | compila conforme ambiente | experimental | testar hardware e GUI |
| voz | depende de executáveis/modelos | depende de executáveis/modelos | experimental | custo de CPU/RAM |
| OpenCV Python | depende de Python/OpenCV | depende de Python/OpenCV | experimental | usar `TAIPythonRuntime` |
| OpenCV nativo | carregamento parcial | carregamento parcial | experimental | processamento nativo incompleto |
| RAG | compila por sample | esperado | experimental | medir memória e índice |

Não promova “provável” para “suportado” sem build e teste repetível.

# Apêndice F - Referências

## Projetos

1. Marcelo Maurin Martins. **Robotinics**. [Repositório do Robotinics](https://github.com/marcelomaurin/robotinics). Snapshot editorial `61d2a19d10e6701e27e46181e1a6c740b8ee4e30`.
2. Marcelo Maurin Martins. **TCHATGPT - AI Component Suite for Lazarus / Free Pascal**. [Repositório do TCHATGPT](https://github.com/marcelomaurin/CHATGPT). Snapshot editorial `15d5e1a7780088701716896cfe9fb3afe0e7b71a`.
3. TCHATGPT. [Compatibilidade por plataforma](https://github.com/marcelomaurin/CHATGPT/blob/15d5e1a7780088701716896cfe9fb3afe0e7b71a/DOC/COMPATIBILIDADE.md).
4. TCHATGPT. [Agent Serial Demo](https://github.com/marcelomaurin/CHATGPT/tree/15d5e1a7780088701716896cfe9fb3afe0e7b71a/pacote/samples/AI%20Agent/agent_serial_demo).
5. TCHATGPT. [Arquitetura de LLM e providers](https://github.com/marcelomaurin/CHATGPT/blob/15d5e1a7780088701716896cfe9fb3afe0e7b71a/pacote/AI/LLM_PROVIDERS.md).

## Documentação técnica oficial

6. Raspberry Pi Ltd. [Getting started - Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/computers/getting-started.html).
7. Arduino. [Arduino IDE 2 - Getting Started](https://docs.arduino.cc/software/ide-v2/tutorials/getting-started/ide-v2-downloading-and-installing).
8. OpenCV. [Installation in Linux](https://docs.opencv.org/4.x/d7/d9f/tutorial_linux_install.html).
9. Texas Instruments. [Cell balancing buys extra run time and battery life](https://www.ti.com/lit/pdf/slyt322).
10. Texas Instruments. [Precise Constant Current Regulation Helps Advance Fast-charging](https://www.ti.com/document-viewer/lit/html/SSZTA38).
11. Fluke. [Digital multimeter safety and measurement guidance](https://media.fluke.com/51012112-8f43-4aa7-a30a-b2e3016e8f2f_original%20file.pdf).
12. Omron. [Explanation of relay terms](https://www.ia.omron.com/support/guide/36/explanation_of_terms.html).

# Apêndice G - Glossário

| Termo | Definição |
|---|---|
| ADC | conversor analógico-digital |
| BMS | sistema de gerenciamento/proteção de bateria |
| CC/CV | carga por corrente constante e tensão constante |
| CI | integração contínua; compilação/teste automatizado |
| Firmware | software executado no microcontrolador |
| GPIO | entrada/saída de propósito geral |
| Heartbeat | mensagem periódica de presença/saúde |
| LLM | modelo de linguagem de grande porte |
| PWM | modulação por largura de pulso |
| RAG | geração aumentada por recuperação de documentos |
| Stall | condição de eixo travado do motor |
| STT | conversão de fala para texto |
| TTS | conversão de texto para fala |
| Watchdog | temporizador que detecta travamento ou ausência de atualização |

# Encerramento

O Robotinics continua sendo mais valioso como plataforma aberta de aprendizagem do que como produto fechado. A terceira edição não apaga a história: ela transforma os erros, limitações e mudanças de tecnologia em parte do ensino.

O princípio central é simples: inteligência artificial amplia a capacidade de conversar, perceber e planejar, mas a segurança do robô permanece determinística, local, mensurável e testável. Com essa divisão, o projeto pode evoluir sem confundir criatividade com autorização.

O próximo passo pertence à comunidade: reproduzir, medir, registrar e melhorar, sempre preservando a origem e a capacidade de verificar cada decisão.
