# Parser de Linguagens Markdown

## **🎯 Objetivo**

O objetivo deste trabalho é desenvolver um **parser simplificado de arquivos JSON**, baseado em fundamentos de **gramáticas livres de contexto** e **autômatos de pilha**, com implementação prática em **Ruby**, utilizando as estruturas nativas da linguagem (Hash, Array, String, Numeric, Boolean, nil).

---

## **📌 Etapas e Entregáveis**

### 1.	**🧾 Definição da Gramática Livre de Contexto (GLC)**

Os alunos deverão definir uma GLC **para um subconjunto bem definido da linguagem**, incluindo pelo menos:

- Objetos ({ "chave": valor, ... })
- Listas ([valor1, valor2, ...])
- Strings
- Números
- Booleanos (true e false)
- Valor null

### 2.	**🧪 Conversão para Forma Normal  ou ajuste da Gramática se necessário**

- **Para CYK, fazer a Forma Normal de Chomsky**
- Para Recursive Descent, ajustar para evitar loops no início

### 3.	**💻 Implementação em Ruby**

Os alunos deverão implementar o parser em Ruby que:

•	**Lê uma string do arquivo Markdown** como entrada.

•	**Valida** a estrutura usando os conceitos do autômato.

•	Converte a entrada Markdown para uma estrutura Ruby:

•	Objetos → Hash

•	Arrays → Array

•	Strings, números, booleanos, null → tipos primitivos equivalentes

O código deverá ser **comentado e modular**, separando a lógica de parsing, validação e estruturação dos dados.

### 4. Adicionar o tipo Cálculo

O tipo cálculo não existe oficialmente em nenhuma linguagem: $19+8$

Assim, quando este tipo for lido, deve devolver o resultado já calculado: 27

Operações para ser reconhecidas:

[Operações](https://www.notion.so/1d8a6ec0abcd8010a210d63424bede01?pvs=21)

O reconhecedor deve emitir as seguintes avisos quando fizer uma reconhecimento conforme tabela abaixo:

Assim, 4+5*2 deve emitir:

["soma", [ "multiplicacao", 5, 2], 4]

Na estrutura de dados, deve resolver a conta.

Exemplos de expressões válidas (deve mostrar que foi aceita):

(1 + 4) * 2^4

7 / ( 1 - 3 )

9^(1 * 6 / 2 + 4)

2 + 4 ^ -4 / 4

Exemplos de expressões inválidas (deve mostrar que não foi aceita):

^ 2 + 4

9 * 2 +

9 + + 3

( ) * 3

( 3 + 3

## 📽️Slides

Deverá ter slides explicando o problema e mostrando 

- A modelagem
- A teoria envolvida e as escolhas
- Explicação básica do código e funções

A não entrega resultará em redução de 3 pontos.

Este trabalho deve seguir:

[Política de uso de ferramentas generativas de IA ](https://www.notion.so/Pol-tica-de-uso-de-ferramentas-generativas-de-IA-1b53bb4e12a54b4aa06eaa02e62192f4?pvs=21) 

[Política antiplágio](https://www.notion.so/Pol-tica-antipl-gio-5187d7b1ab514bfb8424ac0fcfb59dba?pvs=21)

## Linguagens

**🔹 Linguagem 1: JSON**

**📌 Exemplo simples:**

```json
{
  "nome": "João",
  "idade": 30,
  "ativo": true
  "conta": $9/3+21^1$
}
```

**🔗 Referência oficial:**

•	https://www.json.org/json-en.html

**🔹 Linguagem 2: YAML**

**📌 Exemplo simples:**

```yaml
nome: João
idade: 30
ativo: true
conta: $9/3+21^1$
```

**🔗 Referência oficial:**

•	https://yaml.org/spec/

**🔹 Linguagem 3: TOML**

**📌 Exemplo simples:**

```toml
nome = "João"
idade = 30
ativo = true
conta = $9/3+21^1$
```

**🔗 Referência oficial:**

•	https://toml.io/en/
