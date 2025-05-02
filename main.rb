# Representa um token com tipo, valor e posição (linha, coluna)
class Token
  attr_reader :tipo, :valor, :linha, :coluna

  def initialize(tipo, valor, linha = 0, coluna = 0)
    @tipo = tipo
    @valor = valor
    @linha = linha
    @coluna = coluna
  end

  def to_s
    "Token(#{@tipo}, #{@valor.inspect}, linha=#{@linha}, col=#{@coluna})"
  end
end

# Lexer: responsável por dividir o texto de entrada em tokens significativos
class Lexer
  TIPOS_CARACTERES = {
    CHAVE_ESQ: '{',
    CHAVE_DIR: '}',
    COLCHETE_ESQ: '[',
    COLCHETE_DIR: ']',
    PARENTESES_ESQ: '(',
    PARENTESES_DIR: ')',
    VIRGULA: ',',
    DOIS_PONTOS: ':',
    IGUAL: '=',
    CIFRAO: '$',
    PONTO: '.',
    MAIS: '+',
    MENOS: '-',
    MULTIPLICACAO: '*',
    DIVISAO: '/',
    POTENCIA: '^',
    STRING: 'STRING',
    NUMBER: 'NUMBER',
    BOOLEAN: 'BOOLEAN',
    NULL: 'NULL',
    IDENTIFIER: 'IDENTIFIER',
    EOF: 'EOF',
    NEWlinha: 'NEWlinha'
  }

  def initialize(text)
    @text = text
    @pos = 0
    @caractere_atual = @text[@pos]
    @linha = 1
    @coluna = 1
  end

   # Lança erro léxico com posição
  def error
    raise "Erro léxico na posicão #{@pos}, linha #{@linha}, coluna #{@coluna}: caractere invalido '#{@caractere_atual}'"
  end

  # Avança o ponteiro de leitura
  def avanca
    @pos += 1
    @coluna += 1
    
    if @pos > @text.length - 1
      @caractere_atual = nil
    else
      @caractere_atual = @text[@pos]
      if @caractere_atual == "\n"
        @linha += 1
        @coluna = 0
      end
    end
  end

  # Ignora espaços em branco (exceto quebras de linha)
  def pula_espaco
    while @caractere_atual && @caractere_atual.match(/\s/) && @caractere_atual != "\n"
      avanca
    end
  end

  # Ignora comentários iniciados com #
  def ignora_comentario
    while @caractere_atual && @caractere_atual != "\n"
      avanca
    end
  end

  # Retorna identificadores ou palavras-chave (true, false, null)
  def identifier
    result = ''
    start_coluna = @coluna
    
    while @caractere_atual && @caractere_atual.match(/[a-zA-Z0-9_-]/)
      result += @caractere_atual
      avanca
    end
    
    Token.new(:IDENTIFIER, result, @linha, start_coluna)
  end

  # Lê strings com aspas (com escape)
  def string
    result = ''
    start_linha = @linha
    start_coluna = @coluna
    
    quote_char = @caractere_atual
    avanca
    
    while @caractere_atual && @caractere_atual != quote_char
      if @caractere_atual == '\\'
        avanca
        case @caractere_atual
        when 'n'
          result += "\n"
        when 't'
          result += "\t"
        when 'r'
          result += "\r"
        when quote_char
          result += quote_char
        when '\\'
          result += '\\'
        else
          result += @caractere_atual
        end
      else
        result += @caractere_atual
      end
      avanca
    end
    
    avanca if @caractere_atual == quote_char
    
    Token.new(:STRING, result, start_linha, start_coluna)
  end

  # Lê números inteiros e reais
  def number
    result = ''
    start_coluna = @coluna
    is_float = false
    
    while @caractere_atual && @caractere_atual.match(/[0-9]/)
      result += @caractere_atual
      avanca
    end
    
    if @caractere_atual == '.'
      is_float = true
      result += @caractere_atual
      avanca
      
      while @caractere_atual && @caractere_atual.match(/[0-9]/)
        result += @caractere_atual
        avanca
      end
    end
    
    if is_float
      Token.new(:NUMBER, result.to_f, @linha, start_coluna)
    else
      Token.new(:NUMBER, result.to_i, @linha, start_coluna)
    end
  end

  # Função principal para obter o próximo token
  def prox_token
    while @caractere_atual
      if @caractere_atual.match(/\s/) && @caractere_atual != "\n"
        pula_espaco
        next
      end
      
      if @caractere_atual == "\n"
        avanca
        return Token.new(:NEWlinha, "\n", @linha - 1, @coluna)
      end
      
      if @caractere_atual == '#'
        ignora_comentario
        next
      end
      
      if @caractere_atual == '$'
        avanca
        return Token.new(:CIFRAO, '$', @linha, @coluna - 1)
      end
      
      if @caractere_atual == '"' || @caractere_atual == "'"
        return string
      end
      
      if @caractere_atual.match(/[0-9]/)
        return number
      end
      
      # Diferencia identificadores e palavras-chave
      if @caractere_atual.match(/[a-zA-Z_]/)
        token = identifier
        
        case token.valor.downcase
        when 'true'
          return Token.new(:BOOLEAN, true, @linha, token.coluna)
        when 'false'
          return Token.new(:BOOLEAN, false, @linha, token.coluna)
        when 'null', 'nil'
          return Token.new(:NULL, nil, @linha, token.coluna)
        else
          return token
        end
      end
      
      TIPOS_CARACTERES.each do |tipo, valor|
        if valor.is_a?(String) && valor.length == 1 && @caractere_atual == valor
          avanca
          return Token.new(tipo, valor, @linha, @coluna - 1)
        end
      end
      
      error
    end
    
    Token.new(:EOF, nil, @linha, @coluna)
  end

  # Converte todo o texto em uma lista de token
  def tokenize
    tokens = []
    token = prox_token
    
    while token.tipo != :EOF
      tokens << token
      token = prox_token
    end
    
    tokens << token  
    tokens
  end
end

# Parser com Recursive Descent
class Parser
  def initialize(lexer)
    @lexer = lexer
    @current_token = @lexer.prox_token
    @etapas = []  # etapas das operações matemáticas
  end

  def error(message = nil)
    error_msg = message || "Erro: #{@current_token.to_s}"
    raise error_msg
  end

  def eat(token_tipo)
    if @current_token.tipo == token_tipo
      token = @current_token
      @current_token = @lexer.prox_token
      token
    else
      error("Erro: #{@current_token.tipo}")
    end
  end

  # Entrada principal da gramática
  def parse
    result = toml_document
    if @current_token.tipo != :EOF
      error("Erro: #{@current_token.tipo}")
    end
    result
  end

  # Representa um documento TOML
  def toml_document
    document = {}
    
    while @current_token.tipo != :EOF
      case @current_token.tipo
      when :IDENTIFIER
        key, valor = key_valor_pair
        document[key] = valor
      when :COLCHETE_ESQ
        section = parse_table_header
        current_section = ensure_nested_table(document, section)
        
        while @current_token.tipo == :IDENTIFIER
          key, valor = key_valor_pair
          current_section[key] = valor
        end
      when :NEWlinha
        eat(:NEWlinha)
      when :CIFRAO
        calc_valor = parse_calculation
        document["calculation"] = calc_valor
      else
        error("Erro: #{@current_token.tipo}")
      end
    end
    
    document
  end

  # $19+8$
  def parse_calculation
    eat(:CIFRAO)
    result = parse_expression
    eat(:CIFRAO)
    result
  end

  # Calculos
  def parse_expression
    return parse_term_addition
  end

  def parse_term_addition
    esq = parse_term_multiplication
    
    while [:MAIS, :MENOS].include?(@current_token.tipo)
      operator = @current_token.tipo
      
      if operator == :MAIS
        eat(:MAIS)
        dir = parse_term_multiplication
        @etapas << ["soma", esq, dir]
        esq = esq + dir
      elsif operator == :MENOS
        eat(:MENOS)
        dir = parse_term_multiplication
        @etapas << ["subtracao", esq, dir]
        esq = esq - dir
      end
    end
    
    esq
  end

  def parse_term_multiplication
    esq = parse_factor_POTENCIA
    
    while [:MULTIPLICACAO, :DIVISAO].include?(@current_token.tipo)
      operator = @current_token.tipo
      
      if operator == :MULTIPLICACAO
        eat(:MULTIPLICACAO)
        dir = parse_factor_POTENCIA
        @etapas << ["multiplicacao", esq, dir]
        esq = esq * dir
      elsif operator == :DIVISAO
        eat(:DIVISAO)
        dir = parse_factor_POTENCIA
        @etapas << ["divisao", esq, dir]
        esq = esq / dir
      end
    end
    
    esq
  end

  def parse_factor_POTENCIA
    esq = parse_primary
    
    if @current_token.tipo == :POTENCIA
      eat(:POTENCIA)
      dir = parse_factor_POTENCIA  
      @etapas << ["potencia", esq, dir]
      esq = esq ** dir
    end
    
    esq
  end

  def parse_primary
    token = @current_token
    
    case token.tipo
    when :NUMBER
      eat(:NUMBER)
      token.valor
    when :PARENTESES_ESQ
      eat(:PARENTESES_ESQ)
      expr = parse_expression
      eat(:PARENTESES_DIR)
      expr
    when :MENOS
      eat(:MENOS)
      -parse_primary
    else
      error("Erro: #{token.tipo}")
    end
  end

  # Analisa cabeçalho de tabelas [section.subsection]
  def parse_table_header
    eat(:COLCHETE_ESQ)
    sections = []
    
    sections << eat(:IDENTIFIER).valor
    
    while @current_token.tipo == :PONTO
      eat(:PONTO)
      sections << eat(:IDENTIFIER).valor
    end
    
    eat(:COLCHETE_DIR)
    
    eat(:NEWlinha) if @current_token.tipo == :NEWlinha
    
    sections
  end

  # Garante estrutura aninhada para tabelas
  def ensure_nested_table(document, sections)
    current = document
    
    sections[0...-1].each do |section|
      current[section] ||= {}
      current = current[section]
    end
    
    current[sections.last] ||= {}
    current[sections.last]
  end

  # Analisa par chave=valor
  def key_valor_pair
    key = eat(:IDENTIFIER).valor
    eat(:IGUAL)
    valor = parse_valor
    
    eat(:NEWlinha) if @current_token.tipo == :NEWlinha
    
    [key, valor]
  end

  # Analisa valores simples (string, number, boolean, null, array, object)
  def parse_valor
    case @current_token.tipo
    when :STRING
      eat(:STRING).valor
    when :NUMBER
      eat(:NUMBER).valor
    when :BOOLEAN
      eat(:BOOLEAN).valor
    when :NULL
      eat(:NULL).valor
    when :COLCHETE_ESQ
      parse_array
    when :CHAVE_ESQ
      parse_object
    when :CIFRAO
      parse_calculation
    else
      error("Erro: #{@current_token.tipo}")
    end
  end

  # Parse array
  def parse_array
    eat(:COLCHETE_ESQ)
    array = []
    
    unless @current_token.tipo == :COLCHETE_DIR
      array << parse_valor
      
      while @current_token.tipo == :VIRGULA
        eat(:VIRGULA)
        array << parse_valor
      end
    end
    
    eat(:COLCHETE_DIR)
    array
  end

  # Parse object
  def parse_object
    eat(:CHAVE_ESQ)
    object = {}
    
    unless @current_token.tipo == :CHAVE_DIR
      key = eat(:STRING).valor
      eat(:DOIS_PONTOS)
      valor = parse_valor
      object[key] = valor
      
      while @current_token.tipo == :VIRGULA
        eat(:VIRGULA)
        key = eat(:STRING).valor
        eat(:DOIS_PONTOS)
        valor = parse_valor
        object[key] = valor
      end
    end
    
    eat(:CHAVE_DIR)
    object
  end

  def get_etapas
    @etapas
  end
  
  # Formatador de expressões para saída
  def format_etapas
    formatted_etapas = []
    
    @etapas.each do |warning|
      operation, esq, dir = warning
      formatted_etapas << [operation, esq, dir]
    end
    
    formatted_etapas
  end
end

# Classe TOMLParser que combina lexing e parsing
class TOMLParser
  attr_reader :etapas

  def initialize
    @etapas = []
  end

  def parse(input)
    begin
      lexer = Lexer.new(input)
      parser = Parser.new(lexer)
      result = parser.parse
      @etapas = parser.get_etapas
      return result
    rescue => e
      puts "Erro: #{e.message}"
      return nil
    end
  end

  def parse_calculation(input)
    begin
      unless input.start_with?('$') && input.end_with?('$')
        input = "$#{input}$"
      end
      
      lexer = Lexer.new(input)
      parser = Parser.new(lexer)
      result = parser.parse_calculation
      @etapas = parser.format_etapas
      
      return {
        result: result,
        accepted: true,
        etapas: @etapas
      }
    rescue => e
      return {
        result: nil,
        accepted: false,
        error: e.message
      }
    end
  end
  
  # Método para exibir resultado formatado
  def imprimir_resultado_calculo(expression)
    result = parse_calculation(expression)
    
    puts "Expressão: #{expression}"
    if result[:accepted]
      puts "✅ EXPRESSÃO ACEITA"
      puts "Resultado: #{result[:result]}"
      
      if result[:etapas].any?
        puts "Operações executadas:"
        result[:etapas].each do |warning|
          operation, esq, dir = warning
          case operation
          when "soma"
            puts "  - Soma: #{esq} + #{dir} = #{esq + dir}"
          when "subtracao"
            puts "  - Subtração: #{esq} - #{dir} = #{esq - dir}"
          when "multiplicacao"
            puts "  - Multiplicação: #{esq} × #{dir} = #{esq * dir}"
          when "divisao"
            puts "  - Divisão: #{esq} ÷ #{dir} = #{esq / dir}"
          when "potencia"
            puts "  - Potência: #{esq} ^ #{dir} = #{esq ** dir}"
          end
        end
      end
      
      puts "Etapas:"
      p result[:etapas]
    else
      puts "❌ EXPRESSÃO REJEITADA"
    end
    puts "-" * 40
  end
  
  # Teste completo de todos os tipos de dados
  def test_toml_tipos
    toml_string = <<~TOML
      # String simples
      titulo = "TOML Parser Test"
      
      # Números
      inteiro = 42
      decimal = 3.14
      
      # Booleanos
      verdadeiro = true
      falso = false
      
      # Null
      nada = null
      
      # Cálculo
      calculo = $10 * 5 - 2^3$
      
      # Array/Lista
      cores = ["vermelho", "verde", "azul"]
      numeros = [1, 2, 3, 4, 5]
      misto = [1, "dois", true, $5+5$]
      
      # Objeto/Tabela aninhada
      [informacoes]
      nome = "Teste"
      versao = 1.0
      
      [informacoes.autor]
      nome = "Desenvolvedor"
      email = "dev@example.com"
    TOML
    
    puts "=== TESTANDO TODOS OS TIPOS DE DADOS TOML ==="
    resultado = parse(toml_string)
    
    # Verificar se o parsing foi bem-sucedido
    if resultado.nil?
      puts "❌ FALHA NO PARSING DO TOML"
      return
    end
    
    puts "✓ Parsing concluído com sucesso!"
    
    # Imprimir o resultado em formato estruturado
    puts "\n=== RESULTADO DO PARSING ==="
    imprimir_resultado(resultado)
  end
  
  # Método auxiliar para imprimir o resultado de forma organizada
  def imprimir_resultado(obj, indent = 0)
    prefix = "  " * indent
    
    case obj
    when Hash
      puts "#{prefix}{" if indent > 0
      obj.each do |k, v|
        print "#{prefix}#{k}: "
        case v
        when Hash
          puts ""
          imprimir_resultado(v, indent + 1)
        when Array
          puts ""
          imprimir_resultado(v, indent + 1)
        else
          puts "#{v.inspect} (#{v.class})"
        end
      end
      puts "#{prefix}}" if indent > 0
    when Array
      puts "#{prefix}["
      obj.each do |item|
        case item
        when Hash, Array
          imprimir_resultado(item, indent + 1)
        else
          puts "#{prefix}  #{item.inspect} (#{item.class})"
        end
      end
      puts "#{prefix}]"
    else
      puts "#{prefix}#{obj.inspect} (#{obj.class})"
    end
  end
end

if __FILE__ == $0
  parser = TOMLParser.new

  puts "\n=== TESTE DO PARSER DE TOML ===\n"
  
  # Executar o teste completo de tipos TOML
  puts "\n"
  parser.test_toml_tipos

  # Exemplos de expressões válidas
  puts "EXPRESSÕES VÁLIDAS:"
  parser.imprimir_resultado_calculo("(1 + 4) * 2^4")
  parser.imprimir_resultado_calculo("7 / ( 1 - 3 )")
  parser.imprimir_resultado_calculo("9^(1 * 6 / 2 + 4)")
  parser.imprimir_resultado_calculo("2 + 4 ^ -4 / 4")
  
  # Exemplos de expressões inválidas
  puts "\nEXPRESSÕES INVÁLIDAS:"
  parser.imprimir_resultado_calculo("^ 2 + 4")
  parser.imprimir_resultado_calculo("9 * 2 +")
  parser.imprimir_resultado_calculo("9 + + 3")
  parser.imprimir_resultado_calculo("( ) * 3")
  parser.imprimir_resultado_calculo("( 3 + 3")
  
  # Teste de STRINGS com TOML
  toml_string = <<~TOML
  nome = "João"
  idade = 30
  ativo = true
  conta = $9/3+21^1$
  TOML
  puts "\nTESTE DE STRING COM TOML:"
  resultado = parser.parse(toml_string)
  puts resultado.inspect
end