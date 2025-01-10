limit = false
targetInfo = gg.getTargetInfo()
app = targetInfo.packageName
filename = gg.getFile():match("[^/]+$")
if filename ~= "Decode.lua" then
  print("⚠ Do not change file name, please restore to original name!")
  os.exit()
end
function UDPNEW()
function rwmem(Address, SizeOrBuffer)
    assert(Address ~= nil, "[rwmem]: error, provided address is nil.")
    _rw = {}
    if type(SizeOrBuffer) == "number" then
        _ = ""
        for _ = 1, SizeOrBuffer do _rw[_] = { address = (Address - 1) + _, flags = gg.TYPE_BYTE } end
        for v, __ in ipairs(gg.getValues(_rw)) do
            if __.value == 00 and limit == true then
                return _
            end
            _ = _ .. string.format("%02X", __.value & 0xFF)
        end
        return _
    end
    Byte = {}
    SizeOrBuffer:gsub("..", function(x)
        Byte[#Byte + 1] = x
        _rw[#Byte] = { address = (Address - 1) + #Byte, flags = gg.TYPE_BYTE, value = x .. "h" }
    end)
    gg.setValues(_rw)
end

function hexdecode(hex)
    return (hex:gsub("%x%x", function(digits) return string.char(tonumber(digits, 16)) end))
end

function hexencode(str)
    return (str:gsub(".", function(char) return string.format("%2x", char:byte()) end))
end

function Dec2Hex(nValue)
    nHexVal = string.format("%X", nValue)
    sHexVal = nHexVal .. ""
    return sHexVal
end

function ToInteger(number)
    return math.floor(tonumber(number) or error("Could not cast '" .. tostring(number) .. "' to number.'"))
end

function save(data)
    io.open(gg.EXT_STORAGE .. "/udp.txt", "w"):write(hexdecode(data))
    
    gg.toast("Found ✅")
end

 gg.clearResults()
  gg.setRanges(gg.REGION_ANONYMOUS)
  gg.setSpeed(10.0)
  gg.setVisible(false)
 gg.searchNumber(':{"configType":', gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0) 
  local r = gg.getResults(1)
  if #r < 1 then
    
    hc_2 = true
    end 
   if hc_2 then
     gg.searchNumber("h 22 55 73 65 72", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      
      hc_3 = true
    end
  end
  if hc_3 then
     gg.searchNumber("h 22 73 65 72 76 65 72 22 3A 20 22", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      
      hc_4 = true
    end
  end
      
  if hc_4 then
local readedMem = ""
local continue, udpcheck = true, true
if #r < 1 then
udpcheck = false
gg.toast("UDP not detected")
local res = gg.alert("OOPS! UDP Data Not found . Do you want to see other HC configurations?", "YES","NO")
HTTPCustom()
if res == 2 then
continue = false
os.exit()
end
end
  end

local r = gg.getResults(1)
  if limit == false then
    r[1].address = r[1].address - 100
  end
  readedMem = rwmem(r[1].address, 900)
  save(readedMem)
  gg.clearResults()
  
function udpx9()
function udp()
    -- Função para remover bytes nulos do início e do final do texto
    local function removeNullBytes(texto)
        return texto:gsub("^[%z]+", ""):gsub("[%z]+$", "")
    end

    -- Função para tentar encontrar palavras-chave e salvar informações
    local function tentarEncontrarPalavrasChave(conteudo, palavrasChave, label)
        conteudo = removeNullBytes(conteudo)

        for _, palavraChave in ipairs(palavrasChave) do
            local inicio, fim = conteudo:find('"' .. palavraChave .. '"')

            if inicio then
                local inicioJSON = inicio
                local fimJSON = fim

                -- Percorre para trás até encontrar o início real do JSON
                while inicioJSON > 1 and conteudo:sub(inicioJSON - 1, inicioJSON - 1) ~= "\0" do
                    inicioJSON = inicioJSON - 1
                end

                -- Percorre para frente até encontrar o final real do JSON
                while fimJSON < #conteudo and conteudo:sub(fimJSON + 1, fimJSON + 1) ~= "\0" do
                    fimJSON = fimJSON + 1
                end

                local textoCapturado = conteudo:sub(inicioJSON, fimJSON)

                -- Exibe e salva no arquivo
                gg.alert(label .. ": " .. textoCapturado)
                gg.copyText(textoCapturado, false)
                local arquivoSaida = io.open("/sdcard/udp.txt", "a")

                if not arquivoSaida then
                    print("")
                    return
                end

                arquivoSaida:write(label .. ": " .. textoCapturado .. "\n\n")
                arquivoSaida:close()

                return true
            end
        end

        return false
    end

    local function obterEntradaSSH()
        local texto = gg.prompt({"Cole ssh criptografado: "}, nil, {"text"})

        if texto == nil then
            os.exit()
        end

        return texto[1]
    end

    local function salvarTextoEmArquivo(texto, caminhoArquivo)
        if texto == nil or texto == "" then
            return nil, "Texto inválido"
        end

        if caminhoArquivo == nil or caminhoArquivo == "" then
            return nil, "Caminho de arquivo inválido"
        end

        local arquivo = io.open(caminhoArquivo, "w")
        if arquivo == nil then
            return nil, "Não foi possível abrir o arquivo"
        end

        arquivo:write(texto)
        arquivo:close()

        return true
    end

    local function lerTextoDeArquivo(caminhoArquivo)
        if caminhoArquivo == nil or caminhoArquivo == "" then
            return nil, "Caminho de arquivo inválido"
        end

        local arquivo = io.open(caminhoArquivo, "r")
        if arquivo == nil then
            return nil, "Não foi possível abrir o arquivo"
        end

        local conteudo = arquivo:read("*all")
        arquivo:close()

        if conteudo == nil then
            return nil, "Não foi possível ler o conteúdo do arquivo"
        end

        return conteudo
    end

    local function exibirEInserir(arquivoSaida, label, texto)
        
        local sucesso, erro = arquivoSaida:write(label .. ": " .. texto .. "\n\n")

        if not sucesso then
            print("Erro ao escrever no arquivo de saída: " .. erro)
        end
    end
    
    -- Função para decodificar o UDP e salvar no arquivo /sdcard/decrypt.txt    
    function udpxx()
        local caminhoArquivoEntrada = "/sdcard/udp.txt"
        local caminhoArquivoSaida = "/sdcard/udp.txt"

        local arquivoEntrada = io.open(caminhoArquivoEntrada, "r")

        if not arquivoEntrada then
            print("Falha ao abrir o arquivo de entrada: " .. caminhoArquivoEntrada)
            return -- Retorna imediatamente se não puder abrir o arquivo de entrada
        end

        local conteudoEntrada = arquivoEntrada:read("*all")
        arquivoEntrada:close()

        if conteudoEntrada and conteudoEntrada ~= "" then
            local hcRegex = {}
            hcRegex["Udp"] = '"user"%s*:%s*"([^"]+)"%s*,%s*"auth"%s*:%s*"([^"]+)"'

            function bitwise(val1, val2)
                return string.char((tonumber(val1) // (2 ^ tonumber(val2))) % 256)
            end

            function extract(data, iv)
                if type(data) ~= "string" then
                    return nil, nil
                end

                local new_data = ""
                for val1, val2 in string.gmatch(data, "(-?%d+)%.(-?%d+)") do
                    local ivNum = tonumber(iv)
                    if not ivNum then
                        return nil, nil
                    end

                    local val1Num = tonumber(val1)
                    local val2Num = tonumber(val2)

                    if not val1Num or not val2Num then
                        return nil, nil
                    end

                    local val11 = val1Num - ivNum
                    local val22 = val2Num - ivNum

                    local val3 = ((val11 // (2 ^ val22)) % 256)
                    local car = string.char(val3)
                    new_data = new_data .. car
                end

                if verificaString(new_data) then
                    return new_data
                else
                    new_data = ""
                    for val1, val2 in string.gmatch(data, "(-?%d+)%.(-?%d+)") do
                        car = bitwise(val1, val2)
                        new_data = new_data .. car
                    end
                    return new_data
                end
            end

            function verificaString(str)
                for i = 1, #str do
                    local char = str:sub(i, i)
                    local ascii = string.byte(char)
                    if (ascii < 32 or ascii > 126) or (ascii > 90 and ascii < 97) then
                        return false
                    end
                end
                return true
            end

            function calculaIv(user, senha)
                if type(user) ~= "string" or type(senha) ~= "string" then
                    return nil, "Usuário e senha devem ser strings"
                end

                local countU = 0
                local countP = 0
                for match in user:gmatch("(-?%d+)%.(-?%d+)") do
                    countU = countU + 1
                end
                for match in senha:gmatch("(-?%d+)%.(-?%d+)") do
                    countP = countP + 1
                end

                return countU, countP
            end

            function dec_user_pass(user, userIv, pasw, passIv)
                return extract(user, userIv), extract(pasw, passIv)
            end

            local udpUserEnc, udpPassEnc = string.match(conteudoEntrada, hcRegex["Udp"])

            if udpUserEnc and udpPassEnc then
                local userIv, passIv = calculaIv(udpUserEnc, udpPassEnc)

                if userIv and passIv then
                    local udpUser, udpPass = dec_user_pass(udpUserEnc, userIv, udpPassEnc, passIv)

                    if udpUser and udpPass then
                        -- Substitua as instruções print pela lógica desejada
                        local resultadoDecodificado = "Username: " .. udpUser .. "\nPassword: " .. udpPass
                        conteudoEntrada = string.gsub(conteudoEntrada, 'user": "([%d-.]+)"', 'user": "' .. udpUser .. '"')
                        conteudoEntrada = string.gsub(conteudoEntrada, 'auth": "([%d-.]+)"', 'auth": "' .. udpPass .. '"')

                        conteudoEntrada = removeNullBytes(conteudoEntrada)

                        local arquivoSaida = io.open(caminhoArquivoSaida, "w")
                        
                        if not arquivoSaida then
                            
                        else
                            arquivoSaida:write(conteudoEntrada)
                            arquivoSaida:close()
                   
                        end
                    else
                        
                    end
                else
                    
                end
            else
                print("")

            end
        end
    end

    
    udpxx()
end

udp()
end

udpx9()

local f = io.open("/sdcard/udp.txt", "r")
local content = f:read("*all")
f:close()

local f = io.open("/sdcard/udp.txt", "w")
f:write(content)
f:close()

local start = "╭───────────────\n│𝐔𝐃𝐏 𝐂𝐔𝐒𝐓𝐎𝐌 (𝐇𝐂)\n├───────────────\n"
local final = ""

content = string.gsub(content, '"server": "', '",    "server": "')

local app = content:match('udp') or 'udp'
local server_udp = content:match('"server": "(.-)"')
local user_udp = content:match('"user": "(.-)"')
local auth_udp = content:match('"auth": "(%w+)"')
local sni_udp = content:match('"sni": "(.-)"')
local rx_udp = content:match('"rx_receive": (%d+)')
local tx_udp = content:match('"tx_transfer": (%d+)')
local stream_udp = content:match('"stream_buffer": (%d+)')
local receive_udp = content:match('"receive_buffer": (%d+)')
local insicure_udp = content:match('"insecure": (%w+)')
local socks_udp = content:match('"socks5": (%d+)') or "{"
local listen_udp = content:match('"listen": "(.-)"')

local message = start

local function addKey(label, value)
  if value and value ~= "" then
    message = message .. '' .. label .. '' .. value .. '\n'
  end
end

--addKey("user", user_udp)
--addKey("auth", auth_udp)
--addKey("socks", socks_udp)
--addKey("insicure", insicure_udp)
addKey("│𝐒𝐧𝐢: ", sni_udp)
addKey("│𝐑𝐱_𝐫𝐞𝐜𝐞𝐢𝐯𝐞: ", rx_udp)
addKey("│𝐓𝐱_𝐭𝐫𝐚𝐧𝐬𝐟𝐞𝐫: ", tx_udp)
addKey("│𝐒𝐭𝐫𝐞𝐚𝐦_𝐛𝐮𝐟𝐟𝐞𝐫: ", stream_udp)
addKey("│𝐑𝐞𝐜𝐞𝐢𝐯𝐞_𝐛𝐮𝐟𝐟𝐞𝐫: ", receive_udp)
addKey("│𝐋𝐢𝐬𝐭𝐞𝐧: ", listen_udp)
addKey("├───────────────\n│𝐀𝐮𝐭𝐡: `", server_udp ..'@'.. user_udp ..':'.. auth_udp ..'`\n╰───────────────')

if message ~= "" then
  message = message .. final
  gg.alert(message, 'copy json')
  gg.copyText(message, false)
end

local f = io.open("/sdcard/udp.txt", "w")
f:write(message)
print([[⠛⠛⣿⣿⣿⣿⣿⡷⢶⣦⣶⣶⣤⣤⣤⣀⠀⠀⠀
 ⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀
 ⠀⠀⠀⠉⠉⠉⠙⠻⣿⣿⠿⠿⠛⠛⠛⠻⣿⣿⣇⠀
 ⠀⠀⢤⣀⣀⣀⠀⠀⢸⣷⡄⠀⣁⣀⣤⣴⣿⣿⣿⣆
 ⠀⠀⠀⠀⠹⠏⠀⠀⠀⣿⣧⠀⠹⣿⣿⣿⣿⣿⡿⣿
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠿⠇⢀⣼⣿⣿⠛⢯⡿⡟
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠦⠴⢿⢿⣿⡿⠷⠀⣿⠀
 ⠀⠀⠀⠀⠀⠀⠀⠙⣷⣶⣶⣤⣤⣤⣤⣤⣶⣦⠃⠀
 ⠀⠀⠀⠀⠀⠀⠀⢐⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀
 ⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⢿⣿⣿⣿⣿⠟⠁


telegram t.me/mobasniff
]])
f:close()
gg.setVisible(false)
end

function HttpInjector()
function EfeitoThanos()
-- Às vezes alguns arquivos não foram removidos. Isso pode ocorrer por várias razões, como permissões insuficientes ou arquivos não existentes. Vamos tentar com o Efeito Thanos

-- Função para excluir arquivos com a palavra-chave e extensão ".txt"
function excluirArquivosComPalavraChave(palavraChave, ...)
    local listaArquivos = {...}

    for _, nomeArquivo in ipairs(listaArquivos) do
        local nomeCompleto = nomeArquivo .. ".txt"
        local sucesso, motivo = os.remove(nomeCompleto)

        if sucesso then
            gg.toast("Efeito Thanos: " .. nomeCompleto)
        else
            gg.toast("Não me deixe vê: " .. nomeCompleto .. " - Motivo: " .. motivo)
        end
    end
end

-- Exemplo de uso
excluirArquivosComPalavraChave("decrypt",
    "decrypt_x9",
    "json",
    "print",
    "e-hi",
    "ssh",
    "dump",
    "hc_",
    "hc",
    "hc_udp",
    "udp_hc",
    "payload",
    "SNI",
    "easy",
    "udp",
    "login",
    "slowdns",
    "openvpn",
    "proxy",
    "v2ray",
    "json2", 
    "ehi",
    "`ehi",
    "x9_full_message",
    "decrypt6_x9",
    "decrypt5_x9",
    "decrypt3_x9",
    "decrypt2_x9",
    "`decrypt",
    "json_x",
    "f"
    -- Adicione mais nomes de arquivos conforme necessário
)

-- Esta versão da função inclui o motivo de falha ao tentar remover um arquivo. Isso pode ajudar a entender por que alguns arquivos não estão sendo removidos. Analise as mensagens de saída para obter mais informações sobre o problema
end
EfeitoThanos()

function hd(hex)
	-- Remove espaços em branco e caracteres não imprimíveis
	hex = hex:gsub("[^%x ]", "")

	-- Converte cada par de caracteres hexadecimal em um caractere ASCII
	return (hex:gsub("%x%x", function(digits) return string.char(tonumber(digits, 16)) end))
end

-- A função para decodificar uma string hexadecimal em ASCII
function hdh(hex)
    -- Verifica se hex é uma string válida
    if hex == nil or type(hex) ~= "string" then
        print("Erro: Dados de entrada inválidos para a função hd.")
        return
    end

    -- A função `gsub` percorre a string hexadecimal e a converte em caracteres ASCII
    return (string.gsub(hex, "%x%x", function(digits)
        -- A função `tonumber` converte os dígitos hexadecimais em números inteiros
        -- E então, a função `string.char` converte o número em um caractere ASCII correspondente
        return string.char(tonumber(digits, 16))
    end))
end

-- Função Hentai exibe Primeiro as Primas
function hentai() -- A função "hentai()" tem um nome genérico e pode ser substituído por qualquer outro, se você está comprometido, altere

gg.clearResults() -- `gg.clearResults()`: Essa linha de código limpa todos os resultados que foram obtidos anteriormente, caso haja algum.

results = gg.getListItems() -- `results = gg.getListItems()`: Aqui, uma lista de resultados é obtida usando a função `getListItems()`.

gg.removeListItems(results) -- `gg.removeListItems(results)`: Essa linha de código remove todos os itens da lista de resultados obtidos. Isso é feito para garantir que não haja nenhuma interferência ou sobreposição com outros resultados.

-- Exibe o valor em hexadecimal para a cor branca nula 
print(hdh("E385A4")) -- branco nulo

-- Primeiro as primas
print(hdh("E2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A1BFE2A09BE2A09BE2A08BE2A089E2A099E2A0BBE2A0BFE2A0BFE2A0BFE2A0BFE2A2BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BF0AE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A1BFE2A083E2A084E2A084E2A084E2A084E2A084E2A084E2A084E2A084E2A0B9E2A3BFE2A3BFE2A3B6E2A3B6E2A3A6E2A3ACE2A2B9E2A3BFE2A3BF0AE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A083E2A084E2A084E2A084E2A3B0E2A3A7E2A180E2A084E2A084E2A084E2A084E2A088E2A299E2A18BE2A3BFE2A3BFE2A3BFE2A2B8E2A3BFE2A3BF0AE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A084E2A084E2A0B0E2A0BCE2A2AFE2A3BFE2A3BFE2A3A6E2A384E2A084E2A084E2A084E2A088E2A2A1E2A3BFE2A3BFE2A3BFE2A2B8E2A3BFE2A3BF0AE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A084E2A084E2A0B8E2A0A4E2A095E2A09BE2A099E2A0B7E2A3BFE2A186E2A084E2A084E2A084E2A3B8E2A3BFE2A3BFE2A18FE2A3BCE2A3BFE2A3BF0AE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A187E2A084E2A084E2A084E2A084E2A084E2A084E2A084E2A084E2A084E2A084E2A084E2A084E2A3B4E2A3BFE2A3BFE2A3BFE2A2A1E2A3BFE2A3BFE2A3BF0AE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A19FE2A084E2A084E2A084E2A084E2A084E2A384E2A084E2A280E2A084E2A084E2A280E2A3A4E2A3BEE2A3BFE2A3BFE2A3BFE2A283E2A3BEE2A3BFE2A3BFE2A3BF0AE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A0BFE2A39BE2A3A1E2A384E2A380E2A084E2A0A0E2A2B4E2A3BFE2A3BFE2A1BFE2A384E2A3B4E2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A283E2A3BEE2A3BFE2A3BFE2A3BFE2A3BF0AE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A18FE2A3BCE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3A9E2A1BDE2A181E2A2B8E2A3BFE2A3BFE2A3BFE2A3BFE2A3BF0AE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A283E2A3BFE2A3BFE2A29FE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3AEE2A2ABE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A39FE2A2BFE2A083E2A084E2A2BBE2A3BFE2A3BFE2A3BFE2A3BF0AE2A3BFE2A3BFE2A3BFE2A3BFE2A1BFE2A3B8E2A09FE2A3B5E2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BEE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3B7E2A384E2A2B0E2A184E2A2BFE2A3BFE2A3BFE2A3BF0AE2A3BFE2A3BFE2A3BFE2A3BFE2A187E2A08FE2A3BCE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3A6E2A0B9E2A18EE2A3BFE2A3BFE2A3BF0AE2A3ADE2A38DE2A09BE2A0BFE2A084E2A2B0E2A08BE2A189E2A0B9E2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A099E2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A19FE2A281E2A099E2A186E2A2A1E2A3BFE2A3BFE2A3BF0AE2A0BBE2A3BFE2A186E2A084E2A3A4E2A088E2A2A3E2A388E2A3A0E2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A08FE2A384E2A0BBE2A3BFE2A3BFE2A3BFE2A3BFE2A3BFE2A386E2A388E2A3B4E2A083E2A3BFE2A3BFE2A3BFE2A3BF0AE2A180E2A088E2A2BFE2A084E2A3BFE2A187E2A084E2A099E2A0BFE2A3BFE2A1BFE2A0BFE2A28BE2A3A5E2A3BEE2A3BFE2A3B7E2A38CE2A0BBE2A2BFE2A3BFE2A3BFE2A1BFE2A09FE2A3A1E2A3BEE2A3BFE2A3BFE2A0BFE2A28B0AE2A09BE2A0B3E2A084E2A2A0E2A3BFE2A087E2A084E2A3B7E2A191E2A2B6E2A3B6E2A2BFE2A3BFE2A3BFE2A3BFE2A3BDE2A3BFE2A3BFE2A3BFE2A3B6E2A3B6E2A190E2A3B6E2A3BFE2A0BFE2A09BE2A3A9E2A184E2A084E2A2B8")) -- `print desenho hentai`: Essa linha exibe o conteúdo específico de hentai, utilizando o comando "print" para exibir e separar casais

os.exit() -- `os.exit()`: Por fim, a função encerra a execução do programa.
end

-- Função "x9d", Primeiro as Primas - Esta função faz parte de um código mais extenso e desempenha várias tarefas
function x9d()

    -- Inicialização de variáveis
    limit = false  -- Inicializa a variável "limit" como falsa (false).

    -- Tabelas e funções para manipulação de UTF-8
    local utf8 = {}  -- Cria uma tabela chamada "utf8" para auxiliar na manipulação de strings UTF-8.
    local bit = {
        data32 = {}  -- Cria uma tabela chamada "bit" com uma sub-tabela "data32" para operações de bits.
    }

    -- Inicialização da tabela "bit.data32"
    do
        for i = 1, 32 do
            bit.data32[i] = 2 ^ (32 - i)  -- Preenche a tabela "bit.data32" com valores binários de 32 bits.
        end
    end

    -- Função para obter o número de bytes de um caractere UTF-8
    local toby = string.byte
    function utf8.charbytes(s, i)
        i = i or 1  -- Se o índice não for fornecido, assume 1 como padrão.
        local c = string.byte(s, i)  -- Obtém o valor numérico do caractere na posição i.
        if c > 0 and c <= 127 then
            return 1  -- Caractere ASCII de 1 byte.
        end

        if c >= 194 and c <= 223 then
            return 2  -- Caractere UTF-8 de 2 bytes.
        end

        if c >= 224 and c <= 239 then
            return 3  -- Caractere UTF-8 de 3 bytes.
        end

        if c >= 240 and c <= 244 then
            return 4  -- Caractere UTF-8 de 4 bytes.
        end

        return 1  -- Valor padrão, assume 1 byte se não corresponder a nenhum caso acima.
    end

    -- Declaração da função "d2b" como método da tabela "bit"
    local ded
    function bit:d2b(arg)
        if arg == nil then
            return  -- Retorna nil se o argumento for nulo.
        end

        local tr, c = {}, arg < 0
        if c then
            arg = 0 - arg  -- Se o argumento for negativo, torna-o positivo.
        end

        -- Converte o número decimal para binário
        for i_c = 1, 32 do
            if arg >= self.data32[i_c] then
                tr[i_c] = 1
                arg = arg - self.data32[i_c]
            else
                tr[i_c] = 0
            end
        end

        if c then
            tr = self:_bnot(tr)  -- Se o número original era negativo, aplica o complemento de dois.
            tr = self:b2d(tr) + 1  -- Converte de volta para decimal.
            tr = self:d2b(tr)  -- Converte de volta para binário.
        end

        return tr  -- Retorna o valor binário resultante.
    end

    -- Função para converter um número binário em decimal
    function bit:b2d(arg, neg)
        local nr = 0  -- Inicializa o número decimal como 0.

        if arg[1] == 1 and neg == true then
            arg = self:_bnot(arg)  -- Se o primeiro bit for 1 e "neg" for verdadeiro, aplica o complemento de dois.
            nr = self:b2d(arg) + 1  -- Converte de volta para decimal e adiciona 1.
            nr = 0 - nr  -- Torna o número negativo.
        else
            -- Converte o número binário em decimal.
            for i_c = 1, 32 do
                if arg[i_c] == 1 then
                    nr = nr + 2 ^ (32 - i_c)  -- Adiciona o valor do bit à representação decimal.
                end
            end
        end

        return nr  -- Retorna o valor decimal resultante.
    end

    -- Aqui, a função "x9d" deve continuar com sua implementação real. Até agora, apenas a inicialização de variáveis, tabelas e funções foi feita.

    -- O restante da implementação da função "x9d" joguei abaixo

-- Função para realizar a operação lógica "E" bit a bit entre dois números
function bit:_and(a, b)
    -- Converte os números decimais em representações binárias
    local op1 = self:d2b(a)
    local op2 = self:d2b(b)
    local r = {}  -- Inicializa o resultado como uma tabela vazia

    -- Realiza a operação "E" bit a bit
    for i_f = 1, 32 do
        if op1[i_f] == 1 and op2 ~= nil and op2[i_f] == 1 then
            r[i_f] = 1  -- Se ambos os bits forem 1, o resultado é 1
        else
            r[i_f] = 0  -- Caso contrário, o resultado é 0
        end
    end

    -- Essa correção verifica se op2 não é nil antes de tentar acessar op2[i_f]. Isso evita o erro de tentar acessar uma tabela nil com a chave i_f e garante que o código funcione corretamente.

    -- Converte o resultado de volta para decimal como um número negativo (se necessário)
    return self:b2d(r, true)
end

-- Função para realizar a operação lógica "OU" bit a bit entre dois números
function bit:_or(a, b)
    -- Converte os números decimais em representações binárias
    local op1 = self:d2b(a)
    local op2 = self:d2b(b)
    local r = {}  -- Inicializa o resultado como uma tabela vazia

    -- Realiza a operação "OU" bit a bit
    for i_f = 1, 32 do
        if op1[i_f] == 1 or op2[i_f] == 1 then
            r[i_f] = 1  -- Se pelo menos um dos bits for 1, o resultado é 1
        else
            r[i_f] = 0  -- Caso contrário, o resultado é 0
        end
    end

    -- Converte o resultado de volta para decimal como um número negativo (se necessário)
    return self:b2d(r, true)
end

-- Função para realizar a operação lógica "XOR" bit a bit entre dois números
function bit:_xor(a, b)
    -- Converte os números decimais em representações binárias
    local op1 = self:d2b(a)
    if op1 == nil then
        return nil  -- Retorna nil se a conversão falhar
    end

    local op2 = self:d2b(b)
    if op2 == nil then
        return nil  -- Retorna nil se a conversão falhar
    end

    local r = {}  -- Inicializa o resultado como uma tabela vazia

    -- Realiza a operação "XOR" bit a bit
    for i_f = 1, 32 do
        if op1[i_f] == op2[i_f] then
            r[i_f] = 0  -- Se os bits forem iguais, o resultado é 0
        else
            r[i_f] = 1  -- Se os bits forem diferentes, o resultado é 1
        end
    end

    -- Converte o resultado de volta para decimal como um número negativo (se necessário)
    return self:b2d(r, true)
end

-- Tabela de funções para decodificar caracteres UTF-8
local switch = {
    -- Função para decodificar caracteres de 1 byte
    [1] = function(s, pos)
        local c1 = toby(s, pos)  -- Lê o primeiro byte
        return c1  -- Retorna o valor do primeiro byte como o código Unicode
    end,

    -- Função para decodificar caracteres de 2 bytes
    [2] = function(s, pos)
        local c1 = toby(s, pos)  -- Lê o primeiro byte
        local c2 = toby(s, pos + 1)  -- Lê o segundo byte
        local int1 = bit:_and(31, c1)  -- Obtém os 5 bits mais baixos do primeiro byte
        local int2 = bit:_and(63, c2)  -- Obtém os 6 bits mais baixos do segundo byte
        local unicode = bit:_or(bit:_lshift(int1, 6), int2)  -- Combina os bits para obter o código Unicode
        return unicode  -- Retorna o código Unicode do caractere
    end,

    -- Função para decodificar caracteres de 3 bytes
    [3] = function(s, pos)
        local c1 = toby(s, pos)  -- Lê o primeiro byte
        local c2 = toby(s, pos + 1)  -- Lê o segundo byte
        local c3 = toby(s, pos + 2)  -- Lê o terceiro byte
        local int1 = bit:_and(15, c1)  -- Obtém os 4 bits mais baixos do primeiro byte
        local int2 = bit:_and(63, c2)  -- Obtém os 6 bits mais baixos do segundo byte
        local int3 = bit:_and(63, c3)  -- Obtém os 6 bits mais baixos do terceiro byte
        local o2 = bit:_or(bit:_lshift(int1, 12), bit:_lshift(int2, 6))  -- Combina os bits para obter a primeira parte do código Unicode
        local unicode = bit:_or(o2, int3)  -- Combina os bits para obter o código Unicode completo
        return unicode  -- Retorna o código Unicode do caractere
    end,

    -- Função para decodificar caracteres de 4 bytes
    [4] = function(s, pos)
        local c1 = toby(s, pos)  -- Lê o primeiro byte
        local c2 = toby(s, pos + 1)  -- Lê o segundo byte
        local c3 = toby(s, pos + 2)  -- Lê o terceiro byte
        local c4 = toby(s, pos + 3)  -- Lê o quarto byte
        local int1 = bit:_and(15, c1)  -- Obtém os 4 bits mais baixos do primeiro byte
        local int2 = bit:_and(63, c2)  -- Obtém os 6 bits mais baixos do segundo byte
        local int3 = bit:_and(63, c3)  -- Obtém os 6 bits mais baixos do terceiro byte
        local int4 = bit:_and(63, c4)  -- Obtém os 6 bits mais baixos do quarto byte
        local o2 = bit:_or(bit:_lshift(int1, 18), bit:_lshift(int2, 12))  -- Combina os bits para obter a primeira parte do código Unicode
        local o3 = bit:_or(o2, bit:_lshift(int3, 6))  -- Combina os bits para obter a segunda parte do código Unicode
        local unicode = bit:_or(o3, int4)  -- Combina os bits para obter o código Unicode completo
        return unicode  -- Retorna o código Unicode do caractere
    end
}

-- Função para realizar a operação NOT bit a bit em um número binário
function bit:_bnot(op1)
    local r = {}
    for i_b = 1, 32 do
        if op1[i_b] == 1 then
            r[i_b] = 0
        else
            r[i_b] = 1
        end
    end
    return r
end

-- Função para realizar a operação NOT bit a bit em um número decimal
function bit:_not(a)
    local op1 = self:d2b(a)
    local r = self:_bnot(op1)
    return self:b2d(r, true)
end

-- Função para obter os valores de código UTF-16 de uma string UTF-8
function bit:charCodeAt(s)
    if s then
        local pos, int, H, L = 1, 0, 0, 0
        local slen = string.len(s)
        local allByte = {}

        while pos <= slen do
            local tLen = utf8.charbytes(s, pos)

            if tLen >= 1 and tLen <= 4 then
                if tLen == 4 then
                    int = switch[4](s, pos)
                    H = math.floor((int - 65536) / 1024) + 55296
                    L = (int - 65536) % 1024 + 56320
                    table.insert(allByte, H)
                    table.insert(allByte, L)
                else
                    int = switch[tLen](s, pos)
                    table.insert(allByte, int)
                end
            end

            pos = pos + tLen
        end

        return allByte
    else
        -- Trate o caso em que s é nulo
        return nil -- ou retorne algo apropriado
    end
end

-- Função para realizar uma operação de deslocamento à direita (RShift) em um número
function bit:_rshift(a, n)
    local r = 0
    if a < 0 then
        r = 0 - self:_frshift(0 - a, n)
    elseif a >= 0 then
        r = self:_frshift(a, n)
    end
    return r
end

-- Função para realizar uma operação de deslocamento à direita sem sinal (FRShift) em um número
function bit:_frshift(a, n)
    local op1 = self:d2b(a)
    local r = self:d2b(0)
    local left = 32 - n
    if n < 32 and n > 0 then
        for i_f = left, 1, -1 do
            r[i_f + n] = op1[i_f]
        end
    end
    return self:b2d(r)
end

-- Função para realizar uma operação de deslocamento à esquerda (LShift) em um número
function bit:_lshift(a, n)
    local op1 = self:d2b(a)
    local r = self:d2b(0)
    if n < 32 and n > 0 then
        for i_d = n, 31 do
            r[i_d - n + 1] = op1[i_d + 1]
        end
    end
    return self:b2d(r, true)
end

-- Função para remover espaços em branco no início e no fim de uma string
function trim(s)
    return s:match("^%s*(.*)"):match("(.-)%s*$")
end

-- Tabela para manipulação de JSON (pode ser expandida conforme necessário)
local json = {}

-- Função para determinar o tipo de objeto (tabela ou array)
local kind_of = function(obj)
    if type(obj) ~= "table" then
        return type(obj)
    end

    local i = 1
    for i_a in pairs(obj) do
        if obj[i] ~= nil then
            i = i + 1
        else
            return "table"
        end
    end

    if i == 1 then
        return "table"
    end

    return "array"
end
 
-- Função para escapar caracteres especiais em uma string JSON
local escape_str = function(s)
    local in_char = {
        "\\",
        "\"",
        "/",
        "\b",
        "\f",
        "\n",
        "\r",
        "\t"
    }
    local out_char = {
        "\\",
        "\"",
        "/",
        "b",
        "f",
        "n",
        "r",
        "t"
    }
    for i_b, i_c in ipairs(in_char) do
        s = s:gsub(i_c, "\\" .. out_char[i_b])
    end
    return s
end

-- Função para pular delimitadores em uma string JSON
local skip_delim = function(str, pos, delim, err_if_missing)
    pos = pos + #str:match("^%s*", pos)
    if str:sub(pos, pos) ~= delim then
        if err_if_missing then
            error("Esperado " .. delim .. " na posição próxima " .. pos)
        end
        return pos, false
    end
    return pos + 1, true
end

-- Função para analisar o valor de uma string JSON
local function parse_str_val(str, pos, val)
    val = val or ""
    local early_end_error = "Fim da entrada encontrado durante a análise da string."
    if pos > #str then
        error(early_end_error)
    end
    local c = str:sub(pos, pos)
    if c == "\"" then
        return val, pos + 1
    end
    if c ~= "\\" then
        return parse_str_val(str, pos + 1, val .. c)
    end
    local esc_map = {
        b = "\b",
        f = "\f",
        n = "\n",
        r = "\r",
        t = "\t"
    }

-- Continuação da função para analisar o valor de uma string JSON
    local nextc = str:sub(pos + 1, pos + 1)
    if not nextc then
        error(early_end_error)
    end
    return parse_str_val(str, pos + 2, val .. (esc_map[nextc] or nextc))
end

-- Função para analisar um valor numérico em uma string JSON
local parse_num_val = function(str, pos)
    local num_str = str:match("^-?%d+%.?%d*[eE]?[+-]?%d*", pos)
    local val = tonumber(num_str)
    if not val then
        error("Erro ao analisar o número na posição " .. pos .. ".")
    end
    return val, pos + #num_str
end

-- Função para converter um objeto Lua em uma string JSON
function json.stringify(obj, as_key)
    local s = {}
    local kind = kind_of(obj)
    
    if kind == "array" then
        if as_key then
            error("Não é possível codificar um array como chave.")
        end

        s[#s + 1] = "["
        for i_c, i_d in ipairs(obj) do
            if i_c > 1 then
                s[#s + 1] = ", "
            end
            s[#s + 1] = json.stringify(i_d)
        end
        s[#s + 1] = "]"
    elseif kind == "table" then
        if as_key then
            error("Não é possível codificar uma tabela como chave.")
        end

        s[#s + 1] = "{"
        for i_c, i_d in pairs(obj) do
            if #s > 1 then
                s[#s + 1] = ", "
            end
            s[#s + 1] = json.stringify(i_c, true)
            s[#s + 1] = ":"
            s[#s + 1] = json.stringify(i_d)
        end
        s[#s + 1] = "}"
    else
        if kind == "string" then
            return "\"" .. escape_str(obj) .. "\""
        elseif kind == "number" then
            if as_key then
                return "\"" .. tostring(obj) .. "\""
            else
                return tostring(obj)
            end
        elseif kind == "boolean" then
            return tostring(obj)
        elseif kind == "nil" then
            return "null"
        else
            error("Tipo não suportado para conversão em JSON: " .. kind .. ".")
        end
    end

    return table.concat(s)
end

-- Define a constante json.null
json.null = {}

-- Função que analisa uma string JSON e a converte em uma tabela Lua
function json.parse(str, pos, end_delim)
    -- Inicializa a posição de análise (ou utiliza 1 como padrão)
    pos = pos or 1
    
    -- Verifica se a posição é maior que o comprimento da string
    if pos > #str then
        error("Atingiu o fim inesperado da entrada")
    end
    
    -- Remove espaços em branco iniciais e atualiza a posição
    local pos = pos + #str:match("^%s*", pos)
    
    -- Obtém o primeiro caractere da posição atual
    local first = str:sub(pos, pos)
    
    -- Verifica o tipo de estrutura JSON com base no primeiro caractere
    if first == "{" then
        -- Inicializa uma tabela para um objeto JSON
        local obj, key, delim_found = {}, true, true
        
        -- Avança um caractere para dentro do objeto
        pos = pos + 1
        
        -- Inicia um loop para analisar os pares chave-valor do objeto
        while true do
            -- Chama recursivamente a função para analisar a chave
            key, pos = json.parse(str, pos, "}")
            
            -- Se a chave for nula, indica o fim do objeto JSON
            if key == nil then
                return obj, pos
            end
            
            -- Verifica se a vírgula está presente entre os itens do objeto
            if not delim_found then
                error("Vírgula faltando entre os itens do objeto.")
            end
            
            -- Avança para analisar o valor correspondente
            pos = skip_delim(str, pos, ":", true)
            obj[key], pos = json.parse(str, pos)
            
            -- Atualiza a posição e indica se uma vírgula foi encontrada
            pos, delim_found = skip_delim(str, pos, ",")
        end
    elseif first == "[" then
        -- Inicializa uma tabela para um array JSON
        local arr, val, delim_found = {}, true, true
        
        -- Avança um caractere para dentro do array
        pos = pos + 1
        
        -- Inicia um loop para analisar os elementos do array
        while true do
            -- Chama recursivamente a função para analisar o valor do elemento
            val, pos = json.parse(str, pos, "]")
            
            -- Se o valor for nulo, indica o fim do array JSON
            if val == nil then
                return arr, pos
            end
            
            -- Verifica se a vírgula está presente entre os elementos do array
            if not delim_found then
                error("Falta vírgula entre os itens do array.")
            end
            
            -- Adiciona o valor ao array
            arr[#arr + 1] = val
            
            -- Atualiza a posição e indica se uma vírgula foi encontrada
            pos, delim_found = skip_delim(str, pos, ",")
        end
    elseif first == "\"" then
        -- Chama a função para analisar uma string JSON
        do return parse_str_val(str, pos + 1) end
        return
    elseif first == "-" or first:match("%d") then
        -- Chama a função para analisar um valor numérico JSON
        do return parse_num_val(str, pos) end
        return
    elseif first == end_delim then
        -- Retorna nulo e avança para a próxima posição
        do return nil, pos + 1 end
        return
    else
        -- Inicializa uma tabela de literais JSON
        local literals = {
            ["true"] = true,
            ["false"] = false,
            null = json.null
        }
        
        -- Verifica se o primeiro caractere corresponde a um literal JSON
        do
            do
                for i_f, i_e in pairs(literals) do
                    local lit_end = pos + #i_f - 1
                    if str:sub(pos, lit_end) == i_f then
                        return i_e, lit_end + 1
                    end
                end
            end
        end
        
        -- Se nenhum literal for correspondido, gera um erro
        local pos_info_str = "posição " .. pos .. ": " .. str:sub(pos, pos + 10)
        error("sem choro " .. pos_info_str)
    end
end

-- Função para codificar uma string em binário
function enc(data, b)
    -- Inicializa uma variável para armazenar o resultado
    return (data:gsub(".", function(x)
        -- Inicializa uma variável 'r' para armazenar o resultado para cada caractere 'x'
        local r = ""
        -- Obtém o valor ASCII do caractere 'x'
        local byte = x:byte()
        
        -- Converte o valor ASCII para uma representação binária de 8 bits
        for i_b = 8, 1, -1 do
            -- Adiciona '1' ou '0' a 'r' com base nos bits do valor ASCII
            r = r .. (byte % 2 ^ i_b - byte % 2 ^ (i_b - 1) > 0 and "1" or "0")
        end
        
        -- Retorna a representação binária do caractere 'x'
        return r
    end
    ) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
        -- Verifica se a sequência 'x' tem pelo menos 6 caracteres
        if #x < 6 then
            return ""
        end
        
        -- Inicializa uma variável 'c' para calcular o valor decimal
        local c = 0
        
        -- Converte a sequência binária de 6 bits de volta para decimal
        for i_a = 1, 6 do
            c = c + (x:sub(i_a, i_a) == "1" and 2 ^ (6 - i_a) or 0)
        end
        
        -- Retorna o caractere correspondente ao valor decimal 'c' em 'b'
        return b:sub(c + 1, c + 1)
    end
    ) .. ({
      "",
      "??",
      "?"
    })[#data % 3 + 1]
end

-- Função para decodificar uma sequência binária
function dec(data, b)
    -- Remove caracteres que não estão presentes em 'b'
    data = string.gsub(data, "[^" .. b .. "=]", "")
    
    -- Inicializa uma variável para armazenar o resultado
    return (data:gsub(".", function(x)
        -- Verifica se o caractere é '?', que é usado para preenchimento
        if x == "?" then
            return ""
        end
        -- Inicializa uma variável 'r' para armazenar o resultado para cada caractere 'x'
        local r = ""
        -- Encontra a posição do caractere 'x' em 'b'
        local f = b:find(x) - 1
        
        -- Converte a posição 'f' para uma representação binária de 6 bits
        for i_b = 6, 1, -1 do
            r = r .. (f and f % 2 ^ i_b - f % 2 ^ (i_b - 1) > 0 and "1" or "0") or ""
        end
        
        -- Adiciona a representação binária de 'x' a 'result'
        return r
    end
    ):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
        -- Verifica se a sequência 'x' tem exatamente 8 caracteres
        if #x ~= 8 then
            return ""
        end
        
        -- Inicializa uma variável 'c' para calcular o valor decimal
        local c = 0
        
        -- Converte a sequência binária de 8 bits de volta para decimal
        for i_a = 1, 8 do
            c = c + (x:sub(i_a, i_a) == "1" and 2 ^ (8 - i_a) or 0)
        end
        
        -- Verifica se 'c' é um número válido (menor que 256) e retorna o caractere correspondente
        return type(c) == "number" and c < 256 and string.char(c) or ""
    end
    ))
end

-- Função x9 recebe uma chave (key) e dados hexadecimais (data) como entrada.
function x9(key, data)
    -- Verifica se a chave e os dados são válidos
    if key == nil or data == nil or type(key) ~= "string" or type(data) ~= "string" then
        return nil  -- Se os dados não forem válidos, retorne nil
    end

    -- Variáveis para armazenar os dados intermediários e o resultado final
    local preData, result = "", ""

    -- Converte a chave em valores numéricos usando a função bit:charCodeAt
    local bit_key = bit:charCodeAt(key)

    -- Converte dados hexadecimais em bytes
    local c = 0
    local c2 = 1
    while c < #data do
        -- Verifica se há pelo menos dois caracteres para converter
        if c2 + 1 <= #data then
            -- Converte pares de caracteres hexadecimais em bytes e adiciona à preData
            local hexByte = tonumber(string.sub(data, c2, c2 + 1), 16)

            -- Verifica se a conversão do byte foi bem-sucedida
            if hexByte ~= nil and type(hexByte) == "number" then
                preData = preData .. string.char(hexByte)
            end

            c = c + 2
            c2 = c2 + 2
        else
            break  -- Saia do loop se não houver pares de caracteres suficientes
        end
    end

    -- Se a conversão de dados hexadecimais foi bem-sucedida, continue
    if #preData > 0 then
        -- Converte os bytes da preData em valores numéricos usando a função bit:charCodeAt
        local bit_data = bit:charCodeAt(preData)

        -- Aplica a operação XOR byte a byte entre preData e a chave
        local a = 0
        local b = 0
        while a < #preData do
            if b >= #key then
                b = 0
            end

            a = a + 1
            b = b + 1
            local xor = bit:_xor(bit_data[a], bit_key[b])

            -- Verifica se o resultado do XOR é válido e menor que 256 antes de adicioná-lo ao resultado final
            if xor ~= nil and type(xor) == "number" and xor < 256 then
                result = result .. string.char(xor)
            end
        end

        -- Retorna o resultado final
        return result
    end

    return nil  -- Se a conversão dos dados hexadecimais falhar, retorne nil
end

-- Função para verificar se uma string contém apenas caracteres imprimíveis
function isPrintable(s)
    for i = 1, #s do
        local char = s:sub(i, i)
        -- Verifica se o caractere não é um caractere de controle não imprimível
        if char < " " or char > "~" then
            return false
        end
    end
    return true
end

-- Função x9_xEhi recebe um "salt" (valor de sal) e dados como entrada.
function x9_xEhi(salt, data)
    data = dec(string.reverse(data), "RkLC2QaVMPYgGJW/A4f7qzDb9e+t6Hr0Zp8OlNyjuxKcTw1o5EIimhBn3UvdSFXs?")
    return x9(salt, string.sub(data, 1, #data))
  end
  
  -- Função x9_xEhil recebe um "salt" (valor de sal) e dados como entrada.
  function x9_xEhil(salt, data)
    data = dec(string.reverse(data), "t6uxKcTwhBn3UvRkLC2QaVM1o5A4f7Hr0Zp8OyjqzDb9e+dSFXsEIimPYgGJW/lN?")
    return x9(salt, string.sub(data, 1, #data))
  end
  
-- Função x9openEhi recebe um "salt" (valor de sal) e dados como entrada.
function x9openEhi(salt, data)
    -- Verifica se o tipo de "data" é uma string
    if type(data) == "string" then
        -- Inverte a string "data" e decodifica usando a função "dec" com uma chave específica
        data = dec(string.reverse(data), "RkLC2QaVMPYgGJW/A4f7qzDb9e+t6Hr0Zp8OlNyjuxKcTw1o5EIimhBn3UvdSFXs?", "?")
        
        -- Verifica se o valor decodificado é vazio ou contém caracteres não imprimíveis
        if not data or not isPrintable(data) then
            return "N/A"
        else
            -- Retorna o resultado da função "x9" aplicada ao "salt" e aos dados decodificados
            return x9(salt, string.sub(data, 1, #data))
        end
    else
        -- Trata o caso em que "data" não é uma string
        return "N/A"
    end
end

-- Função x9openEhil recebe um "salt" (valor de sal) e dados como entrada.
function x9openEhil(salt, data)
    -- Verifica se o tipo de "data" é uma string
    if type(data) == "string" then
        -- Inverte a string "data" e decodifica usando a função "dec" com uma chave específica
        data = dec(string.reverse(data), "t6uxKcTwhBn3UvRkLC2QaVM1o5A4f7Hr0Zp8OyjqzDb9e+dSFXsEIimPYgGJW/lN?", "?")
        
        -- Verifica se o valor decodificado é vazio ou contém caracteres não imprimíveis
        if not data or not isPrintable(data) then
            return "N/A"
        else
            -- Retorna o resultado da função "x9" aplicada ao "salt" e aos dados decodificados
            return x9(salt, string.sub(data, 1, #data))
        end
    else
        -- Trata o caso em que "data" não é uma string
        return "N/A"
    end
end

-- Função para converter uma tabela Lua em uma representação JSON
function JSONStringify(table)
    -- Verifica se o argumento passado é uma tabela
    if type(table) ~= "table" then
        return "null" -- Se não for uma tabela, retorna "null" (valor JSON nulo)
    end

    -- Função interna para serializar uma tabela Lua em uma string JSON
    local function serialize(tbl)
        local result = {} -- Cria uma tabela vazia para armazenar os pares chave-valor JSON
        for k, v in pairs(tbl) do
            local key, value = "", ""

            -- Verifica o tipo da chave (deve ser número ou string)
            if type(k) == "number" then
                key = "[" .. k .. "]" -- Se for número, formata a chave entre colchetes
            elseif type(k) == "string" then
                key = '["' .. k .. '"]' -- Se for string, formata a chave entre aspas e colchetes
            else
                error("JSONStringify: Chaves de tabela devem ser números ou strings.") -- Erro se a chave não for número nem string
            end

            -- Verifica o tipo do valor e formata-o adequadamente
            if type(v) == "number" or type(v) == "boolean" then
                value = tostring(v) -- Números e booleanos são convertidos em strings simples
            elseif type(v) == "string" then
                value = '"' .. v .. '"' -- Strings são colocadas entre aspas duplas
            elseif type(v) == "table" then
                value = serialize(v) -- Se for uma tabela aninhada, chama a função de serialização recursivamente
            else
                error("JSONStringify: Tipos de valor não suportados.") -- Erro se o tipo de valor não for suportado
            end

            -- Concatena a chave e o valor formatados e adiciona-os à tabela de resultados
            table.insert(result, key .. ":" .. value)
        end
        -- Retorna a representação JSON da tabela completa, envolta por chaves
        return "{" .. table.concat(result, ",") .. "}"
    end

    -- Chama a função interna de serialização e retorna o resultado
    return serialize(table)
end

-- Variáveis globais ehi e configSalt para armazenar informações
local ehi, configSalt

-- Classe Http
local Http = {}

-- Função de inicialização da classe Http com os dados fornecidos
function Http:New(data)
  ehi = data

  -- Verifica se o "configSalt" nos dados é uma string vazia, nula ou não está presente
  if data and (data.configSalt == nil or data.configSalt == "") then
    configSalt = "EVZJNI"
  elseif data and data.configSalt then
    configSalt = data.configSalt
  else
    -- Define um valor padrão se o campo "configSalt" não existir nos dados
    configSalt = "EVZJNI"
  end
end

--[[
-- Função para decodificar um valor específico com base na versão da configuração
function Http:Dec(key)
    -- Verifica se ehi é uma tabela e configSalt está presente e não é vazio; caso contrário, usa um valor padrão
    local salt = (type(ehi) == "table" and ehi.configSalt and ehi.configSalt ~= "") and ehi.configSalt or "EVZJNI"

    if ehi and ehi.configVersionCode and ehi[key] then
        local configVersion = tonumber(ehi.configVersionCode)

        -- Verifica se as funções x9openEhi e x9openEhil estão definidas
        local decodeFunction
        if configVersion and configVersion == 14222 and x9openEhil then
            decodeFunction = x9openEhil
        elseif configVersion and configVersion >= 49 and configVersion <= 1000 and x9openEhi then
            decodeFunction = x9openEhi
        else
            -- Use x9openEhil como padrão se a versão não estiver nos intervalos desejados ou se as funções não estiverem definidas
            decodeFunction = x9openEhil
        end

        -- Tenta decodificar usando a função apropriada
        local decodedValue = decodeFunction(salt, ehi[key])

        -- Verifica se o valor decodificado é válido
        if decodedValue and decodedValue ~= "" and decodedValue ~= "N/A" then
            return decodedValue
        else
            -- Se o valor decodificado não for válido, retorna o valor original
            return ehi[key]
        end
    else
        -- Usa x9openEhil como padrão se ehi ou ehi.configVersionCode não estiverem presentes
        return x9openEhil and x9openEhil(salt, ehi and ehi[key]) or "primeiro as primas"
    end
end

]]--

--[[

Dentro da função `Http:Dec(key)`, o valor padrão para a versão é definido como "1". Isso significa que se `configVersionCode` não for especificado ou estiver vazio, será atribuído o valor padrão.

Em seguida, é feita uma verificação para garantir que `configVersionCode` seja um número. Se não for um número, ele é convertido usando a função `tonumber()`. Se a conversão não for bem-sucedida, `configVersionCode` será definido como o valor padrão.

Depois disso, a função verifica se `configVersionCode` é maior que 10000. Se for, ela verifica se existe um valor correspondente a `key` em `ehi` e, se existir, chama a função `x9openEhil(configSalt, ehi[key])` e retorna o resultado. Se não existir um valor correspondente, ele retorna "N/A".

Caso `configVersionCode` seja menor ou igual a 10000, a função faz exatamente a mesma verificação para verificar a existência de um valor correspondente a `key` em `ehi`. Se existir, também chama a função `x9openEhi(configSalt, ehi[key])` e retorna o resultado. Se não existir um valor correspondente, ele retorna "N/A".

]]--

function Http:Dec(key)
    -- Define a versão padrão da configuração
    local defaultConfigVersionCode = "1"  

    -- Verifica se há uma versão de configuração definida; se não, utiliza a versão padrão
    local configVersionCode = ehi.configVersionCode
    if not configVersionCode or configVersionCode == "" then
        configVersionCode = defaultConfigVersionCode
    -- Se a versão não for um número, tenta converter; se não for possível, usa a versão padrão
    elseif type(configVersionCode) ~= "number" then
        configVersionCode = tonumber(configVersionCode)
        if not configVersionCode then
            configVersionCode = defaultConfigVersionCode
        end
    end

    -- Se a versão de configuração for maior que 10000, decodifica o valor usando um método específico
    if configVersionCode and tonumber(configVersionCode) > 10000 then
        if ehi[key] then
            return x9openEhil(configSalt, ehi[key])
        else
            return "N/A"  -- Retorna "N/A" se a chave não existir
        end
    else
        -- Se a versão for menor ou igual a 10000, decodifica o valor usando um método padrão
        if ehi[key] then
            return x9openEhi(configSalt, ehi[key])
        else
            return "N/A"  -- Retorna "N/A" se a chave não existir
        end
    end
end

-- Função para verificar se um valor está incluído em uma tabela
local includes = function(tab, val)
    for i_a, i_b in ipairs(tab) do
        if i_b == val then
            return true -- Retorna verdadeiro se o valor for encontrado na tabela
        end
    end
    return false -- Retorna falso se o valor não for encontrado na tabela
end

-- Carrega o módulo JSON
local math = require('math')
local string = require("string")
local table = require("table")

-- Declaração do módulo
local json = {}             -- Namespace público
local json_private = {}     -- Namespace privado

-- Constantes públicas
json.EMPTY_ARRAY={}
json.EMPTY_OBJECT={}

-- Funções públicas

-- Funções privadas
local decode_scanArray
local decode_scanComment
local decode_scanConstant
local decode_scanNumber
local decode_scanObject
local decode_scanString
local decode_scanWhitespace
local encodeString
local isArray
local isEncodable

-- Funções Públicas

--- Codifica um objeto/variável Lua arbitrário.
-- @param v O objeto/variável Lua a ser codificado em JSON.
-- @return String contendo a codificação JSON no formato interno de string Lua (ou seja, não unicode)
function json.encode (v)
-- Lidar com valores nulos (nil)
if v==nil then
return "null"
end

local vtype = type(v)

-- Lidar com strings
if vtype=='string' then
return '"' .. json_private.encodeString(v) .. '"'	    -- Precisa lidar com a codificação em string
end

-- Lidar com booleans
if vtype=='number' or vtype=='boolean' then
return tostring(v)
end

-- Lidar com tabelas
if vtype=='table' then
local rval = {}
-- Considere matrizes (arrays) separadamente
local bArray, maxCount = isArray(v)
if bArray then
for i = 1,maxCount do
table.insert(rval, json.encode(v[i]))
end
else	-- Um objeto, não um array
for i,j in pairs(v) do
if isEncodable(i) and isEncodable(j) then
table.insert(rval, '"' .. json_private.encodeString(i) .. '":' .. json.encode(j))
end
end
end
if bArray then
return '[' .. table.concat(rval,',') ..']'
else
return '{' .. table.concat(rval,',') .. '}'
end
end

-- Lidar com valores nulos (null)
if vtype=='function' and v==json.null then
return 'null'
end

assert(false,'codificar tentativa de codificar tipo não suportado ' .. vtype .. ':' .. tostring(v))
end

--- Decodifica uma string JSON e retorna o valor decodificado como uma estrutura/valor de dados Lua.
-- @param s A string a ser varrida, escaneada
-- @param [startPos] Posição inicial opcional onde a string JSON está localizada. O padrão é 1.
-- @param Objeto Lua, número O objeto que foi verificado, como uma tabela Lua / string / número / booleano ou nulo (boolean ou nil), e a posição do primeiro caractere após o objeto JSON verificado.
function json.decode(s, startPos)
startPos = startPos and startPos or 1
startPos = decode_scanWhitespace(s,startPos)
assert(startPos<=string.len(s), 'Objeto codificado JSON não terminado encontrado na posição em [' .. s .. ']')
local curChar = string.sub(s,startPos,startPos)
-- Object
if curChar=='{' then
return decode_scanObject(s,startPos)
end
-- Array
if curChar=='[' then
return decode_scanArray(s,startPos)
end
-- Number
if string.find("+-0123456789.e", curChar, 1, true) then
return decode_scanNumber(s,startPos)
end
-- String
if curChar==[["]] or curChar==[[']] then
return decode_scanString(s,startPos)
end
if string.sub(s,startPos,startPos+1)=='/*' then
return json.decode(s, decode_scanComment(s,startPos))
end
-- Caso contrário, deve ser uma constante
return decode_scanConstant(s,startPos)
end

--- A função nula permite especificar um valor nulo em uma matriz associativa (que de outra forma é descartado se você definir o valor como 'nil' em Lua. Simplesmente set t = { first=json.null }
function json.null()
return json.null -- então json.null() também retornará nulo
end
-- Internal, PRIVATE functions.
-- Seguindo uma convenção semelhante ao Python, prefixei todos esses 'PRIVATE'
-- funções com um sublinhado.

--- Verifica um array de JSON em um objeto Lua
-- startPos começa no início do array.
-- Retorna o array e a próxima posição inicial
-- @param s A string que está sendo verificada.
-- @param startPos A posição inicial da varredura, do scan.
-- @return table, int A matriz digitalizada como uma tabela e a posição do próximo caractere a ser digitalizado.
function decode_scanArray(s,startPos)
local array = {}	-- O valor de retorno
local stringLen = string.len(s)
assert(string.sub(s,startPos,startPos)=='[','decode_scanArray chamado, mas o array não começa na posição ' .. startPos .. ' na string:\n'..s )
startPos = startPos + 1
-- Loop infinito para elementos do array
local index = 1
repeat
startPos = decode_scanWhitespace(s,startPos)
assert(startPos<=stringLen,'JSON String terminou inesperadamente a varredura da matriz.')
local curChar = string.sub(s,startPos,startPos)
if (curChar==']') then
return array, startPos+1
end
if (curChar==',') then
startPos = decode_scanWhitespace(s,startPos+1)
end
assert(startPos<=stringLen, 'JSON String terminou inesperadamente a varredura da matriz.')
object, startPos = json.decode(s,startPos)
array[index] = object
index = index + 1
until false
end

--- Verifica um comentário e descarta o comentário.
-- Retorna a posição do próximo caractere após o comentário.
-- @param string s A string JSON a ser varrida, escaneada.
-- @param int startPos A posição inicial do comentário
function decode_scanComment(s, startPos)
assert( string.sub(s,startPos,startPos+1)=='/*', "decode_scanComment chamado, mas o comentário não começa na posição " .. startPos)
local endPos = string.find(s,'*/',startPos+2)
assert(endPos~=nil, "Comentário não terminado na string em " .. startPos)
return endPos+2
end

-- Verifica constantes fornecidas: true, false ou null
-- Retorna o tipo Lua apropriado e a posição do próximo caractere a ser lido.
-- @param s A string que está sendo verificada, escaneada.
-- @param startPos A posição na string na qual iniciar a varredura, ao scan.
-- @return object, int O objeto (true, false ou nil) e a posição na qual o próximo caractere deve estar digitalizado.
function decode_scanConstant(s, startPos)
local consts = { ["true"] = true, ["false"] = false, ["null"] = nil }
local constNames = {"true","false","null"}

for i,k in pairs(constNames) do
if string.sub(s,startPos, startPos + string.len(k) -1 )==k then
return consts[k], startPos + string.len(k)
end
end
assert(nil, 'Falha ao verificar a constante da string ' .. s .. ' na posição inicial ' .. startPos)
end

-- Verifica um número da string codificada em JSON, também é capaz de digitalizar +- eqns numéricos, o que não é na especificação JSON.
-- Retorna o número e a posição do próximo caractere depois do número.
-- @param s A string que está sendo verificada, escaneada.
-- @param startPos A posição na qual iniciar a digitalização, ao scan.
-- @return number, in O número da extração e a posição do próximo caractere a ser digitalizado, escaneado.
function decode_scanNumber(s,startPos)
local endPos = startPos+1
local stringLen = string.len(s)
local acceptableChars = "+-0123456789.e"
while (string.find(acceptableChars, string.sub(s,endPos,endPos), 1, true)
and endPos<=stringLen
) do
endPos = endPos + 1
end
local stringValue = 'return ' .. string.sub(s,startPos, endPos-1)
local stringEval = load(stringValue)
assert(stringEval, 'Falha ao digitalizar o número [ ' .. stringValue .. '] na string JSON na posição ' .. startPos .. ' : ' .. endPos)
return stringEval(), endPos
end

-- Verifica um objeto JSON em um objeto Lua.
-- startPos começa no início do objeto.
-- Retorna o objeto e a próxima posição inicial.
-- @param s A string que está sendo verificada, escaneada.
-- @param startPos A posição inicial da varredura.
-- @return table, int O objeto digitalizado como uma tabela e a posição do próximo caractere a ser digitalizado, escaneado
function decode_scanObject(s,startPos)
local object = {}
local stringLen = string.len(s)
local key, value
assert(string.sub(s,startPos,startPos)=='{','decode_scanObject chamado, mas o objeto não começa na posição ' .. startPos .. ' na string:\n' .. s)
startPos = startPos + 1
repeat
startPos = decode_scanWhitespace(s,startPos)
assert(startPos<=stringLen, 'JSON string terminou inesperadamente durante a verificação do objeto.')
local curChar = string.sub(s,startPos,startPos)
if (curChar=='}') then
return object,startPos+1
end
if (curChar==',') then
startPos = decode_scanWhitespace(s,startPos+1)
end
assert(startPos<=stringLen, 'JSON string terminou inesperadamente a verificação do objeto.')
-- Digitaliza, escaneia a chave
key, startPos = json.decode(s,startPos)
assert(startPos<=stringLen, 'JSON string terminou inesperadamente procurando pelo valor da chave ' .. key)
startPos = decode_scanWhitespace(s,startPos)
assert(startPos<=stringLen, 'JSON string terminou inesperadamente procurando pelo valor da chave ' .. key)
assert(string.sub(s,startPos,startPos)==':','JSON object key-value tarefa mal formada em ' .. startPos)
startPos = decode_scanWhitespace(s,startPos+1)
assert(startPos<=stringLen, 'JSON string terminou inesperadamente procurando pelo valor da chave ' .. key)
value, startPos = json.decode(s,startPos)
object[key]=value
until false	-- loop infinito enquanto pares de valores-chave são encontrados
end

-- INICIAR SoniEx2
-- Inicialize algumas coisas usadas por decode_scanString
-- Seja mais específico, Bob
local escapeSequences = {
["\\t"] = "\t",
["\\f"] = "\f",
["\\r"] = "\r",
["\\n"] = "\n",
["\\b"] = "\b"
}
setmetatable(escapeSequences, {__index = function(t,k)
-- pular "\" também conhecido como strip escape
return string.sub(k,2)
end}) -- FIM SoniEx2

--- Verifica uma string JSON desde a vírgula invertida ou aspas simples de abertura até o fim da string.
-- Retorna a string extraída como uma string Lua, e a posição do próximo caractere não-string (após a vírgula invertida ou aspas simples de fechamento).
-- @param s A string que está sendo verificada.
-- @param startPos A posição inicial da varredura.
-- @return string, int A string extraída como uma string Lua e o próximo caractere a ser analisado.
function decode_scanString(s,startPos)
assert(startPos, 'decode_scanString(..) chamado sem posição inicial')
local startChar = string.sub(s,startPos,startPos) -- INICIAR SoniEx2

-- Você acredita que aspas simples sejam um JSON válido?
assert(startChar == [["]] or startChar == [[']],'decode_scanString pediu um non-string')

--assert(startPos, "Falha na decodificação da string: falta de fechamento " .. startChar .. " para string na posição " .. oldStart)
local t = {}
local i,j = startPos,startPos
while string.find(s, startChar, j+1) ~= j+1 do
local oldj = j
i,j = string.find(s, "\\.", j+1)
local x,y = string.find(s, startChar, oldj+1)
if not i or x < i then
i,j = x,y-1
end
table.insert(t, string.sub(s, oldj+1, i-1))
if string.sub(s, i, j) == "\\u" then
local a = string.sub(s,j+1,j+4)
j = j + 4
local n = tonumber(a, 16)
assert(n, "Falha na decodificação de string: incorreto Unicode escape " .. a .. " na posição " .. i .. " : " .. j)
-- math.floor(x/2^y) == lazy right shift
-- a % 2^b == bitwise_and(a, (2^b)-1)
-- 64 = 2^6
-- 4096 = 2^12 (or 2^6 * 2^6)
local x
if n < 0x80 then
x = string.char(n % 0x80)
elseif n < 0x800 then
-- [110x xxxx] [10xx xxxx]
x = string.char(0xC0 + (math.floor(n/64) % 0x20), 0x80 + (n % 0x40))
else
-- [1110 xxxx] [10xx xxxx] [10xx xxxx]
x = string.char(0xE0 + (math.floor(n/4096) % 0x10), 0x80 + (math.floor(n/64) % 0x40), 0x80 + (n % 0x40))
end
table.insert(t, x)
else
table.insert(t, escapeSequences[string.sub(s, i, j)])
end
end
table.insert(t,string.sub(j, j+1))
assert(string.find(s, startChar, j+1), "Falha na decodificação da string: falta de fechamento " .. startChar .. " na posição " .. j .. "(para string na posição " .. startPos .. ")")
return table.concat(t,""), j+2
-- FIM SoniEx2
end

--- Verifica uma string JSON ignorando todos os espaços em branco da posição inicial atual.
-- Retorna a posição do primeiro caractere que não seja espaço em branco ou nulo (nil) se todo o final da string for atingido.
-- @param s A string que está sendo verificada, escaneada
-- @param startPos A posição inicial onde devemos começar a remover os espaços em branco.
-- @return int A primeira posição onde não foi encontrado espaço em branco, ou string.len(s)+1 se for o final da string alcançada
function decode_scanWhitespace(s,startPos)
local whitespace=" \n\r\t"
local stringLen = string.len(s)
while ( string.find(whitespace, string.sub(s,startPos,startPos), 1, true)  and startPos <= stringLen) do
startPos = startPos + 1
end
return startPos
end

-- Codifica uma string para ser compatível com JSON.
-- Isso envolve apenas aspas invertidas, aspas invertidas e novas linhas, talvez
-- @param s A string a ser retornada como uma string codificada em JSON (ou seja, string entre aspas)
-- @return A escape de String apropriada

local escapeList = {
['"']  = '\\"',
['\\'] = '\\\\',
['/']  = '\\/',
['\b'] = '\\b',
['\f'] = '\\f',
['\n'] = '\\n',
['\r'] = '\\r',
['\t'] = '\\t'
}

function json_private.encodeString(s)
local s = tostring(s)
return s:gsub(".", function(c) return escapeList[c] end) -- SoniEx2: compatibilidade com 5.0
end

-- Determina se o tipo Lua fornecido é um array ou uma tabela/dicionário.
-- Consideramos qualquer tabela um array se ela tiver índices 1..n para seus n itens, e não outros dados na tabela. Esse método é bobo, é o que temos pra hoje.
-- @param t A tabela a ser avaliada como um array
-- @return boolean, number true se a tabela puder ser representada como um array, false caso contrário. Se for true, o segundo valor retornado é o máximo número de elementos indexados na matriz.
function isArray(t)
-- Em seguida contamos todos os elementos, garantindo que quaisquer elementos não indexados não sejam codificáveis (com a possível exceção de 'n')
if (t == json.EMPTY_ARRAY) then return true, 0 end
if (t == json.EMPTY_OBJECT) then return false end

local maxIndex = 0
for k,v in pairs(t) do
if (type(k)=='number' and math.floor(k)==k and 1<=k) then	-- k,v é um par indexado
if (not isEncodable(v)) then return false end	-- Todos os elementos da matriz devem ser codificáveis
maxIndex = math.max(maxIndex,k)
else
if (k=='n') then
if v ~= (t.n or #t) then return false end  -- false se n não contém o número de elementos
else -- Mais de (k=='n')
if isEncodable(v) then return false end
end  -- Fim do (k~='n')
end -- Fim de k,v não é um par indexado
end  -- Fim do loop em todos os pares
return true, maxIndex
end

-- Determina se o objeto/tabela/variável Lua fornecido pode ser codificado em JSON. A única dos tipos que podem ser codificados em JSON são: string, boolean, number, nil, table e json.null. Nesta implementação, todos os outros tipos são ignorados.
-- @param o O objeto a ser examinado.
-- @return boolean true se o objeto deve ser codificado em JSON, false se deve ser ignorado.
function isEncodable(o)
local t = type(o)
return (t=='string' or t=='boolean' or t=='number' or t=='nil' or t=='table') or
(t=='function' and o==json.null)
end

-- Carrega o módulo JSON com exemplo fuleiro do dkjson
local function dkjson()
-- Opções de módulo:
local always_use_lpeg = false
local register_global_module_table = false
local global_module_name = 'json'

-- dependências globais:
local pairs, type, tostring, tonumber, getmetatable, setmetatable, rawset =
      pairs, type, tostring, tonumber, getmetatable, setmetatable, rawset
local error, require, pcall, select = error, require, pcall, select
local floor, huge = math.floor, math.huge
local strrep, gsub, strsub, strbyte, strchar, strfind, strlen, strformat =
      string.rep, string.gsub, string.sub, string.byte, string.char,
      string.find, string.len, string.format
local strmatch = string.match
local concat = table.concat

local json = { version = "dkjson 2.6" }

local jsonlpeg = {}

if register_global_module_table then
  if always_use_lpeg then
    _G[global_module_name] = jsonlpeg
  else
    _G[global_module_name] = json
  end
end

local _ENV = nil -- bloqueando globais em Lua 5.2 e posterior

pcall (function()
  -- Habilite o acesso a metatabelas bloqueadas. Não se preocupe, este módulo não muda nada neles.
  local debmeta = require "debug".getmetatable
  if debmeta then getmetatable = debmeta end
end)

json.null = setmetatable ({}, {
  __tojson = function () return "null" end
})

local function isarray (tbl)
  local max, n, arraylen = 0, 0, 0
  for k,v in pairs (tbl) do
    if k == 'n' and type(v) == 'number' then
      arraylen = v
      if v > max then
        max = v
      end
    else
      if type(k) ~= 'number' or k < 1 or floor(k) ~= k then
        return false
      end
      if k > max then
        max = k
      end
      n = n + 1
    end
  end
  if max > 10 and max > arraylen and max > n * 2 then
    return false -- não crie uma matriz com muitos buracos
  end
  return true, max
end

local escapecodes = {
  ["\""] = "\\\"", ["\\"] = "\\\\", ["\b"] = "\\b", ["\f"] = "\\f",
  ["\n"] = "\\n",  ["\r"] = "\\r",  ["\t"] = "\\t"
}

local function escapeutf8 (uchar)
  local value = escapecodes[uchar]
  if value then
    return value
  end
  local a, b, c, d = strbyte (uchar, 1, 4)
  a, b, c, d = a or 0, b or 0, c or 0, d or 0
  if a <= 0x7f then
    value = a
  elseif 0xc0 <= a and a <= 0xdf and b >= 0x80 then
    value = (a - 0xc0) * 0x40 + b - 0x80
  elseif 0xe0 <= a and a <= 0xef and b >= 0x80 and c >= 0x80 then
    value = ((a - 0xe0) * 0x40 + b - 0x80) * 0x40 + c - 0x80
  elseif 0xf0 <= a and a <= 0xf7 and b >= 0x80 and c >= 0x80 and d >= 0x80 then
    value = (((a - 0xf0) * 0x40 + b - 0x80) * 0x40 + c - 0x80) * 0x40 + d - 0x80
  else
    return ""
  end
  if value <= 0xffff then
    return strformat ("\\u%.4x", value)
  elseif value <= 0x10ffff then
    -- codificar como par substituto UTF-16
    value = value - 0x10000
    local highsur, lowsur = 0xD800 + floor (value/0x400), 0xDC00 + (value % 0x400)
    return strformat ("\\u%.4x\\u%.4x", highsur, lowsur)
  else
    return ""
  end
end

local function fsub (str, pattern, repl)
  -- gsub sempre cria uma nova string em um buffer, mesmo quando não há correspondência existe. Primeiro, usar find deve ser mais eficiente quando a maioria das strings
  -- não contém o padrão.
  if strfind (str, pattern) then
    return gsub (str, pattern, repl)
  else
    return str
  end
end

local function quotestring (value)
  -- regex "escapável" roubado 
  value = fsub (value, "[%z\1-\31\"\\\127]", escapeutf8)
  if strfind (value, "[\194\216\220\225\226\239]") then
    value = fsub (value, "\194[\128-\159\173]", escapeutf8)
    value = fsub (value, "\216[\128-\132]", escapeutf8)
    value = fsub (value, "\220\143", escapeutf8)
    value = fsub (value, "\225\158[\180\181]", escapeutf8)
    value = fsub (value, "\226\128[\140-\143\168-\175]", escapeutf8)
    value = fsub (value, "\226\129[\160-\175]", escapeutf8)
    value = fsub (value, "\239\187\191", escapeutf8)
    value = fsub (value, "\239\191[\176-\191]", escapeutf8)
  end
  return "\"" .. value .. "\""
end
json.quotestring = quotestring

local function replace(str, o, n)
  local i, j = strfind (str, o, 1, true)
  if i then
    return strsub(str, 1, i-1) .. n .. strsub(str, j+1, -1)
  else
    return str
  end
end

-- funções num2str e str2num independentes de localidade
local decpoint, numfilter

local function updatedecpoint ()
  decpoint = strmatch(tostring(0.5), "([^05+])")
  -- construir um filtro que possa ser usado para remover separadores de grupo
  numfilter = "[^0-9%-%+eE" .. gsub(decpoint, "[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0") .. "]+"
end

updatedecpoint()

local function num2str (num)
  return replace(fsub(tostring(num), numfilter, ""), decpoint, ".")
end

local function str2num (str)
  local num = tonumber(replace(str, ".", decpoint))
  if not num then
    updatedecpoint()
    num = tonumber(replace(str, ".", decpoint))
  end
  return num
end

local function addnewline2 (level, buffer, buflen)
  buffer[buflen+1] = "\n"
  buffer[buflen+2] = strrep ("  ", level)
  buflen = buflen + 2
  return buflen
end

function json.addnewline (state)
  if state.indent then
    state.bufferlen = addnewline2 (state.level or 0,
                           state.buffer, state.bufferlen or #(state.buffer))
  end
end

local encode2 -- declaração de encaminhamento

local function addpair (key, value, prev, indent, level, buffer, buflen, tables, globalorder, state)
  local kt = type (key)
  if kt ~= 'string' and kt ~= 'number' then
    return nil, "type '" .. kt .. "' não é compatível como chave pelo JSON."
  end
  if prev then
    buflen = buflen + 1
    buffer[buflen] = ","
  end
  if indent then
    buflen = addnewline2 (level, buffer, buflen)
  end
  buffer[buflen+1] = quotestring (key)
  buffer[buflen+2] = ":"
  return encode2 (value, indent, level, buffer, buflen + 2, tables, globalorder, state)
end

local function appendcustom(res, buffer, state)
  local buflen = state.bufferlen
  if type (res) == 'string' then
    buflen = buflen + 1
    buffer[buflen] = res
  end
  return buflen
end

local function exception(reason, value, state, buffer, buflen, defaultmessage)
  defaultmessage = defaultmessage or reason
  local handler = state.exception
  if not handler then
    return nil, defaultmessage
  else
    state.bufferlen = buflen
    local ret, msg = handler (reason, value, state, defaultmessage)
    if not ret then return nil, msg or defaultmessage end
    return appendcustom(ret, buffer, state)
  end
end

function json.encodeexception(reason, value, state, defaultmessage)
  return quotestring("<" .. defaultmessage .. ">")
end

encode2 = function (value, indent, level, buffer, buflen, tables, globalorder, state)
  local valtype = type (value)
  local valmeta = getmetatable (value)
  valmeta = type (valmeta) == 'table' and valmeta -- only tables
  local valtojson = valmeta and valmeta.__tojson
  if valtojson then
    if tables[value] then
      return exception('reference cycle', value, state, buffer, buflen)
    end
    tables[value] = true
    state.bufferlen = buflen
    local ret, msg = valtojson (value, state)
    if not ret then return exception('custom encoder failed', value, state, buffer, buflen, msg) end
    tables[value] = nil
    buflen = appendcustom(ret, buffer, state)
  elseif value == nil then
    buflen = buflen + 1
    buffer[buflen] = "null"
  elseif valtype == 'number' then
    local s
    if value ~= value or value >= huge or -value >= huge then
      -- Este é o comportamento da implementação JSON original.
      s = "null"
    else
      s = num2str (value)
    end
    buflen = buflen + 1
    buffer[buflen] = s
  elseif valtype == 'boolean' then
    buflen = buflen + 1
    buffer[buflen] = value and "true" or "false"
  elseif valtype == 'string' then
    buflen = buflen + 1
    buffer[buflen] = quotestring (value)
  elseif valtype == 'table' then
    if tables[value] then
      return exception('reference cycle', value, state, buffer, buflen)
    end
    tables[value] = true
    level = level + 1
    local isa, n = isarray (value)
    if n == 0 and valmeta and valmeta.__jsontype == 'object' then
      isa = false
    end
    local msg
    if isa then -- JSON array
      buflen = buflen + 1
      buffer[buflen] = "["
      for i = 1, n do
        buflen, msg = encode2 (value[i], indent, level, buffer, buflen, tables, globalorder, state)
        if not buflen then return nil, msg end
        if i < n then
          buflen = buflen + 1
          buffer[buflen] = ","
        end
      end
      buflen = buflen + 1
      buffer[buflen] = "]"
    else -- JSON object
      local prev = false
      buflen = buflen + 1
      buffer[buflen] = "{"
      local order = valmeta and valmeta.__jsonorder or globalorder
      if order then
        local used = {}
        n = #order
        for i = 1, n do
          local k = order[i]
          local v = value[k]
          if v ~= nil then
            used[k] = true
            buflen, msg = addpair (k, v, prev, indent, level, buffer, buflen, tables, globalorder, state)
            prev = true -- adicione um separador antes do próximo elemento
          end
        end
        for k,v in pairs (value) do
          if not used[k] then
            buflen, msg = addpair (k, v, prev, indent, level, buffer, buflen, tables, globalorder, state)
            if not buflen then return nil, msg end
            prev = true -- adicione um separador antes do próximo elemento
          end
        end
      else -- não ordenado
        for k,v in pairs (value) do
          buflen, msg = addpair (k, v, prev, indent, level, buffer, buflen, tables, globalorder, state)
          if not buflen then return nil, msg end
          prev = true -- adicione um separador antes do próximo elemento
        end
      end
      if indent then
        buflen = addnewline2 (level - 1, buffer, buflen)
      end
      buflen = buflen + 1
      buffer[buflen] = "}"
    end
    tables[value] = nil
  else
    return exception ('unsupported type', value, state, buffer, buflen,
      "type '" .. valtype .. "' não é compatível com JSON.")
  end
  return buflen
end

function json.encode (value, state)
  state = state or {}
  local oldbuffer = state.buffer
  local buffer = oldbuffer or {}
  state.buffer = buffer
  updatedecpoint()
  local ret, msg = encode2 (value, state.indent, state.level or 0,
                   buffer, state.bufferlen or 0, state.tables or {}, state.keyorder, state)
  if not ret then
    error (msg, 2)
  elseif oldbuffer == buffer then
    state.bufferlen = ret
    return true
  else
    state.bufferlen = nil
    state.buffer = nil
    return concat (buffer)
  end
end

local function loc (str, where)
  local line, pos, linepos = 1, 1, 0
  while true do
    pos = strfind (str, "\n", pos, true)
    if pos and pos < where then
      line = line + 1
      linepos = pos
      pos = pos + 1
    else
      break
    end
  end
  return "line " .. line .. ", column " .. (where - linepos)
end

local function unterminated (str, what, where)
  return nil, strlen (str) + 1, "unterminated " .. what .. " at " .. loc (str, where)
end

-- O erro anteriormente estava ocorrendo em relação a uma função  strlen  que estava sendo chamada com uma string nula. O erro indicava que a função esperava uma string como argumento, mas estava recebendo  nil  em vez disso.

-- Corrigimos usando uma verificação em que se a string  str  é passada como argumento para a função  strlen  ela é nula antes de chamá-la.

-- Aqui vai a diversão:

local function scanwhite(str, pos)
  if str == nil then return nil end -- Verificar se a string é nula
  while true do
    pos = strfind(str, "%S", pos)
    if not pos then return nil end
    local sub2 = strsub(str, pos, pos + 1)
    if sub2 == "\239\187" and strsub(str, pos + 2, pos + 2) == "\191" then
      -- UTF-8 Byte Order Mark
      pos = pos + 3
    elseif sub2 == "//" then
      pos = strfind(str, "[\n\r]", pos + 2)
      if not pos then return nil end
    elseif sub2 == "/*" then
      pos = strfind(str, "*/", pos + 2)
      if not pos then return nil end
      pos = pos + 2
    else
      return pos
    end
  end
end

-- Ao adicionar a verificação  if str == nil then return nil end , você evita o erro de chamar a função  strlen  com uma string nula.

local escapechars = {
  ["\""] = "\"", ["\\"] = "\\", ["/"] = "/", ["b"] = "\b", ["f"] = "\f",
  ["n"] = "\n", ["r"] = "\r", ["t"] = "\t"
}

local function unichar (value)
  if value < 0 then
    return nil
  elseif value <= 0x007f then
    return strchar (value)
  elseif value <= 0x07ff then
    return strchar (0xc0 + floor(value/0x40),
                    0x80 + (floor(value) % 0x40))
  elseif value <= 0xffff then
    return strchar (0xe0 + floor(value/0x1000),
                    0x80 + (floor(value/0x40) % 0x40),
                    0x80 + (floor(value) % 0x40))
  elseif value <= 0x10ffff then
    return strchar (0xf0 + floor(value/0x40000),
                    0x80 + (floor(value/0x1000) % 0x40),
                    0x80 + (floor(value/0x40) % 0x40),
                    0x80 + (floor(value) % 0x40))
  else
    return nil
  end
end

local function scanstring (str, pos)
  local lastpos = pos + 1
  local buffer, n = {}, 0
  while true do
    local nextpos = strfind (str, "[\"\\]", lastpos)
    if not nextpos then
      return unterminated (str, "string", pos)
    end
    if nextpos > lastpos then
      n = n + 1
      buffer[n] = strsub (str, lastpos, nextpos - 1)
    end
    if strsub (str, nextpos, nextpos) == "\"" then
      lastpos = nextpos + 1
      break
    else
      local escchar = strsub (str, nextpos + 1, nextpos + 1)
      local value
      if escchar == "u" then
        value = tonumber (strsub (str, nextpos + 2, nextpos + 5), 16)
        if value then
          local value2
          if 0xD800 <= value and value <= 0xDBff then
            -- temos o alto substituto do UTF-16. Verifique se existe um substituto baixo escapou nas proximidades para combiná-los.
            if strsub (str, nextpos + 6, nextpos + 7) == "\\u" then
              value2 = tonumber (strsub (str, nextpos + 8, nextpos + 11), 16)
              if value2 and 0xDC00 <= value2 and value2 <= 0xDFFF then
                value = (value - 0xD800)  * 0x400 + (value2 - 0xDC00) + 0x10000
              else
                value2 = nil -- caso estivesse fora do alcance de um substituto baixo
              end
            end
          end
          value = value and unichar (value)
          if value then
            if value2 then
              lastpos = nextpos + 12
            else
              lastpos = nextpos + 6
            end
          end
        end
      end
      if not value then
        value = escapechars[escchar] or escchar
        lastpos = nextpos + 2
      end
      n = n + 1
      buffer[n] = value
    end
  end
  if n == 1 then
    return buffer[1], lastpos
  elseif n > 1 then
    return concat (buffer), lastpos
  else
    return "", lastpos
  end
end

local scanvalue -- declaração de encaminhamento

local function scantable (what, closechar, str, startpos, nullval, objectmeta, arraymeta)
  local len = strlen (str)
  local tbl, n = {}, 0
  local pos = startpos + 1
  if what == 'object' then
    setmetatable (tbl, objectmeta)
  else
    setmetatable (tbl, arraymeta)
  end
  while true do
    pos = scanwhite (str, pos)
    if not pos then return unterminated (str, what, startpos) end
    local char = strsub (str, pos, pos)
    if char == closechar then
      return tbl, pos + 1
    end
    local val1, err
    val1, pos, err = scanvalue (str, pos, nullval, objectmeta, arraymeta)
    if err then return nil, pos, err end
    pos = scanwhite (str, pos)
    if not pos then return unterminated (str, what, startpos) end
    char = strsub (str, pos, pos)
    if char == ":" then
      if val1 == nil then
        return nil, pos, "cannot use nil as table index (at " .. loc (str, pos) .. ")"
      end
      pos = scanwhite (str, pos + 1)
      if not pos then return unterminated (str, what, startpos) end
      local val2
      val2, pos, err = scanvalue (str, pos, nullval, objectmeta, arraymeta)
      if err then return nil, pos, err end
      tbl[val1] = val2
      pos = scanwhite (str, pos)
      if not pos then return unterminated (str, what, startpos) end
      char = strsub (str, pos, pos)
    else
      n = n + 1
      tbl[n] = val1
    end
    if char == "," then
      pos = pos + 1
    end
  end
end

scanvalue = function (str, pos, nullval, objectmeta, arraymeta)
  pos = pos or 1
  pos = scanwhite (str, pos)
  if not pos then
    return nil, strlen (str) + 1, "nenhum valor JSON válido (reached the end)"
  end
  local char = strsub (str, pos, pos)
  if char == "{" then
    return scantable ('object', "}", str, pos, nullval, objectmeta, arraymeta)
  elseif char == "[" then
    return scantable ('array', "]", str, pos, nullval, objectmeta, arraymeta)
  elseif char == "\"" then
    return scanstring (str, pos)
  else
    local pstart, pend = strfind (str, "^%-?[%d%.]+[eE]?[%+%-]?%d*", pos)
    if pstart then
      local number = str2num (strsub (str, pstart, pend))
      if number then
        return number, pend + 1
      end
    end
    pstart, pend = strfind (str, "^%a%w*", pos)
    if pstart then
      local name = strsub (str, pstart, pend)
      if name == "true" then
        return true, pend + 1
      elseif name == "false" then
        return false, pend + 1
      elseif name == "null" then
        return nullval, pend + 1
      end
    end
    return nil, pos, "nenhum valor JSON válido em " .. loc (str, pos)
  end
end

local function optionalmetatables(...)
  if select("#", ...) > 0 then
    return ...
  else
    return {__jsontype = 'object'}, {__jsontype = 'array'}
  end
end

function json.decode (str, pos, nullval, ...)
  local objectmeta, arraymeta = optionalmetatables(...)
  return scanvalue (str, pos, nullval, objectmeta, arraymeta)
end

function json.use_lpeg ()
  local g = require ("lpeg")

  if g.version() == "0.11" then
    error "devido a um bug no LPeg 0.11, ele não pode ser usado para correspondência JSON"
  end

  local pegmatch = g.match
  local P, S, R = g.P, g.S, g.R

  local function ErrorCall (str, pos, msg, state)
    if not state.msg then
      state.msg = msg .. " at " .. loc (str, pos)
      state.pos = pos
    end
    return false
  end

  local function Err (msg)
    return g.Cmt (g.Cc (msg) * g.Carg (2), ErrorCall)
  end

  local function ErrorUnterminatedCall (str, pos, what, state)
    return ErrorCall (str, pos - 1, "unterminated " .. what, state)
  end

  local SingleLineComment = P"//" * (1 - S"\n\r")^0
  local MultiLineComment = P"/*" * (1 - P"*/")^0 * P"*/"
  local Space = (S" \n\r\t" + P"\239\187\191" + SingleLineComment + MultiLineComment)^0

  local function ErrUnterminated (what)
    return g.Cmt (g.Cc (what) * g.Carg (2), ErrorUnterminatedCall)
  end

  local PlainChar = 1 - S"\"\\\n\r"
  local EscapeSequence = (P"\\" * g.C (S"\"\\/bfnrt" + Err "unsupported escape sequence")) / escapechars
  local HexDigit = R("09", "af", "AF")
  local function UTF16Surrogate (match, pos, high, low)
    high, low = tonumber (high, 16), tonumber (low, 16)
    if 0xD800 <= high and high <= 0xDBff and 0xDC00 <= low and low <= 0xDFFF then
      return true, unichar ((high - 0xD800)  * 0x400 + (low - 0xDC00) + 0x10000)
    else
      return false
    end
  end
  local function UTF16BMP (hex)
    return unichar (tonumber (hex, 16))
  end
  local U16Sequence = (P"\\u" * g.C (HexDigit * HexDigit * HexDigit * HexDigit))
  local UnicodeEscape = g.Cmt (U16Sequence * U16Sequence, UTF16Surrogate) + U16Sequence/UTF16BMP
  local Char = UnicodeEscape + EscapeSequence + PlainChar
  local String = P"\"" * (g.Cs (Char ^ 0) * P"\"" + ErrUnterminated "string")
  local Integer = P"-"^(-1) * (P"0" + (R"19" * R"09"^0))
  local Fractal = P"." * R"09"^0
  local Exponent = (S"eE") * (S"+-")^(-1) * R"09"^1
  local Number = (Integer * Fractal^(-1) * Exponent^(-1))/str2num
  local Constant = P"true" * g.Cc (true) + P"false" * g.Cc (false) + P"null" * g.Carg (1)
  local SimpleValue = Number + String + Constant
  local ArrayContent, ObjectContent

  -- As funções parse array e parse object analisam apenas um único valor/par de cada vez e armazene-os diretamente para evitar atingir os limites do LPeg.
  local function parsearray (str, pos, nullval, state)
    local obj, cont
    local start = pos
    local npos
    local t, nt = {}, 0
    repeat
      obj, cont, npos = pegmatch (ArrayContent, str, pos, nullval, state)
      if cont == 'end' then
        return ErrorUnterminatedCall (str, start, "array", state)
      end
      pos = npos
      if cont == 'cont' or cont == 'last' then
        nt = nt + 1
        t[nt] = obj
      end
    until cont ~= 'cont'
    return pos, setmetatable (t, state.arraymeta)
  end

  local function parseobject (str, pos, nullval, state)
    local obj, key, cont
    local start = pos
    local npos
    local t = {}
    repeat
      key, obj, cont, npos = pegmatch (ObjectContent, str, pos, nullval, state)
      if cont == 'end' then
        return ErrorUnterminatedCall (str, start, "object", state)
      end
      pos = npos
      if cont == 'cont' or cont == 'last' then
        t[key] = obj
      end
    until cont ~= 'cont'
    return pos, setmetatable (t, state.objectmeta)
  end

  local Array = P"[" * g.Cmt (g.Carg(1) * g.Carg(2), parsearray)
  local Object = P"{" * g.Cmt (g.Carg(1) * g.Carg(2), parseobject)
  local Value = Space * (Array + Object + SimpleValue)
  local ExpectedValue = Value + Space * Err "value expected"
  local ExpectedKey = String + Err "key expected"
  local End = P(-1) * g.Cc'end'
  local ErrInvalid = Err "invalid JSON"
  ArrayContent = (Value * Space * (P"," * g.Cc'cont' + P"]" * g.Cc'last'+ End + ErrInvalid)  + g.Cc(nil) * (P"]" * g.Cc'empty' + End  + ErrInvalid)) * g.Cp()
  local Pair = g.Cg (Space * ExpectedKey * Space * (P":" + Err "colon expected") * ExpectedValue)
  ObjectContent = (g.Cc(nil) * g.Cc(nil) * P"}" * g.Cc'empty' + End + (Pair * Space * (P"," * g.Cc'cont' + P"}" * g.Cc'last' + End + ErrInvalid) + ErrInvalid)) * g.Cp()
  local DecodeValue = ExpectedValue * g.Cp ()

  jsonlpeg.version = json.version
  jsonlpeg.encode = json.encode
  jsonlpeg.null = json.null
  jsonlpeg.quotestring = json.quotestring
  jsonlpeg.addnewline = json.addnewline
  jsonlpeg.encodeexception = json.encodeexception
  jsonlpeg.using_lpeg = true

  function jsonlpeg.decode (str, pos, nullval, ...)
    local state = {}
    state.objectmeta, state.arraymeta = optionalmetatables(...)
    local obj, retpos = pegmatch (DecodeValue, str, pos, nullval, state)
    if state.msg then
      return nil, state.pos, state.msg
    else
      return obj, retpos
    end
  end

  -- resultado de cache desta função:
  json.use_lpeg = function () return jsonlpeg end
  jsonlpeg.use_lpeg = json.use_lpeg

  return jsonlpeg
end

if always_use_lpeg then
  return json.use_lpeg()
end
return json
end

local json = dkjson()  -- Certifique-se de que a biblioteca 'dkjson' está corretamente carregada lá no morro

local function readAndCleanJsonFile(file)
    local f, errorMessage = io.open(file, "r")

    if not f then
        print("Não foi possível abrir o arquivo:", errorMessage)
        return nil
    end

    local content = f:read("*all")

    if not content or content == "" then
        print("Conteúdo vazio ou nulo no arquivo:", file)
        f:close()
        return nil
    end

    -- Remove espaços em branco, caracteres não imprimíveis e bytes nulos do início e final
    content = content:gsub("[^%g{}]", "")

    local index = content:find("{")

    if not index then
        gg.alert("Hoje não, João Kleber")
        print("O conteúdo do arquivo não contém um '{' válido.")
        f:close()
        return nil
    end

    content = content:sub(index)

    f:close()
    return content
end

local jsonFilePath = "/sdcard/json.txt"
local jsonContent = readAndCleanJsonFile(jsonFilePath)

if not jsonContent or jsonContent == "" then
    print("Não foi possível ler ou limpar o conteúdo do JSON:", jsonFilePath)
    return
end

local decodedData, decodeError = json.decode(jsonContent)

if decodedData then
    local timestamp = decodedData.configTimestamp

    if timestamp then
        -- Continue aqui com o restante do código
    else
        print("Aviso: Este JSON não contém 'configTimestamp'. Prossiga com as decodificações.")
    end
else
    print("Não foi possível decodificar o JSON. Erro:", decodeError)
    return
end

-- Atualize o jsonData com o conteúdo do arquivo /sdcard/json.txt
local jsonFixFilePath = "/sdcard/json.txt"
jsonData = json.decode(readAndCleanJsonFile(jsonFixFilePath))

-- Função para converter um valor em timestamp para data formatada
function timestampToData(timestamp)
    if not timestamp then
        return "primeiro as primas" -- Retorna "primeiro as primas" se o timestamp for nulo
    end

    local numericTimestamp = tonumber(timestamp)

    if numericTimestamp then
        return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
    end

    return "primeiro as primas" -- Retorna "primeiro as primas" em caso de erro
end

-- Vamos supor que você queira converter o campo "configTimestamp" do jsonData em uma data formatada
local timestamp = jsonData.configTimestamp

-- Usa a função para converter o timestamp em data
local dataFormatada = timestampToData(timestamp)

-- dataFormatada agora contém a data formatada correspondente ao timestamp em jsonData.configTimestamp
-- Você pode usar dataFormatada como desejar

-- Função para decodificar o Tunnel Type
function getTunnelDescription(tunnelType)
    local tunnelDescriptions = {
        http_obfs_shadowsocks = "HTTP (Obfs) ➔ Shadowsocks - TCP (HTTP)",
        ssl_proxy_payload_ssh = "SSL/TLS Proxy ➔ SSH (Custom Payload) - TCP (TLS)",
        ssl_ssh = "SSL/TLS ➔ SSH - TCP (TLS)",
        proxy_payload_ssh = "HTTP Proxy ➔ SSH (Custom Payload) - TCP (HTTP)",
        proxy_ssh = "HTTP Proxy ➔ SSH - TCP (HTTP)",
        direct_ssh = "SSH (Direct) - TCP",
        direct_shadowsocks = "Shadowsocks (Direct) - TCP (SOCKS)",
        dnstt_ssh = "DNS (DNSTT) ➔ SSH - DNS (UDP/TCP)",
        ssl_proxy_ssh = "SSL/TLS Proxy ➔ SSH - TCP (TLS)",
        ssl_shadowsocks = "SSL/TLS ➔ Shadowsocks - TCP (TLS)",
        tls_obfs_shadowsocks = "SSL/TLS (Obfs) ➔ Shadowsocks - TCP (TLS)",
        direct_v2r_vmess = "V2Ray",
        direct_v2r = "V2Ray/Xray - TCP (HTTP2/WS) | UDP (QUIC/mKCP)",
        hysteria = "Hysteria - UDP",
        direct_payload_ssh = "Direct SSH ➔ (Custom Payload) - TCP"
    }
    
    return tunnelDescriptions[tunnelType] or tunnelType
end

-- Chame a função getTunnelDescription para obter a descrição do Tunnel Type
local tunnelDescription = getTunnelDescription(decodedData.tunnelType)

-- Abre o arquivo no modo de escrita
local outputFile = io.open("/sdcard/ehi.txt", "w")

-- Verifica se o arquivo foi aberto com sucesso
if outputFile then
    -- Resto da função com a coleta e salvamento de dados...

-- Função para ler o conteúdo de um arquivo
function readFromFile(filename)
    local file = io.open(filename, "r")
    if file then
        local content = file:read("*a")
        file:close()
        return content
    else
        return nil
    end
end

-- Função para salvar dados em um arquivo local (/sdcard/ehi.txt)
function save(data)
    local outputFileName = "/sdcard/ehi.txt"

    -- Abre o arquivo no modo de escrita no diretório do script
    local outputFile = io.open(outputFileName, "w")

    if outputFile then
        outputFile:write(data)
        gg.toast("🔓 Te peguei, Lionel Richie!")
        outputFile:close()  -- Fecha o arquivo imediatamente após escrever nele
    else
        -- Lidar com erro ao abrir o arquivo
        gg.alert("Pai não encontrado")
        --print("Falha ao abrir o arquivo de saída")
    end
end

-- Função para salvar os resultados no arquivo e também imprimir na tela.
-- Parâmetros:
--   key: A chave que identifica o resultado.
--   value: O valor associado à chave que deve ser salvo e impresso.
function saveResult(key, value)
    -- Verifica se o valor não é nulo, não é uma string vazia e não é "N/A".
    if value ~= nil and value ~= "" and value ~= "N/A" then
        -- Converte o valor em uma string.
        local valueString = tostring(value)
        -- Salva a chave e o valor no arquivo com quebra de linha.
        save(key .. ":" .. valueString .. "\n")
        -- Imprime a chave e o valor na tela.
        print(key .. ":" .. valueString)
    -- Caso o valor seja nulo.
    elseif value == nil then
        -- Cria uma string vazia.
        local valueString = ""
        -- Salva a chave com uma string vazia no arquivo com quebra de linha.
        save(key .. ":" .. valueString .. "\n")
        -- Imprime a chave com uma string vazia na tela.
        print(key .. ":" .. valueString)
    end
end

-- Exemplo de uso das funções save e saveResult.
-- Tempo atual
--local timestamp = os.time()
-- Salvar o tempo atual
--saveResult("Timestamp", timestamp)
-- Salvar outro resultado
--saveResult("Resultado", "Algum valor")

-- Função que verifica se um Tunnel Type está presente em uma lista de tipos de túnel válidos.
-- Parâmetros:
--   tunnelType: O Tunnel Type que desejamos verificar.
--   tunnelList: A lista de tipos de túnel válidos onde procuramos.
-- Retorno:
--   true se tunnelType estiver na lista, caso contrário, retorna false.

function isTunnelTypeValid(tunnelType, tunnelList)
    -- Itera por cada Tunnel Type na lista.
    for _, validTunnel in pairs(tunnelList) do
        -- Verifica se o Tunnel Type atual é igual a tunnelType.
        if validTunnel == tunnelType then
            -- Se encontrarmos uma correspondência, retornamos true.
            return true
        end
    end
    -- Se não encontrarmos uma correspondência após percorrer a lista inteira, retornamos false.
    return false
end

-- Lista de tipos de túneis reconhecidos
local lista_de_tipos_de_tuneis = {
    "http_obfs_shadowsocks",
  "tls_obfs_shadowsocks",
  "direct_shadowsocks",
  "ssl_shadowsocks",
  "direct_v2r_vmess",
  "direct_v2r",
  "hysteria",
  "dnstt_ssh",
  "direct_ssh",
  "direct_payload_ssh",
  "proxy_payload_ssh",
  "ssl_proxy_payload_ssh",
  "ssl_ssh",
  "ssl_proxy_ssh",
  "proxy_ssh"
    -- Adicione outros tipos de túnel aqui
}

-- Função para verificar se um Tunnel Type é válido
function TunnelTypeX9(tunnelType)
    -- Verifique se a tabela de tipos de túneis é definida
    if not lista_de_tipos_de_tuneis then
        return false
    end

    -- Verifique se o Tunnel Type está na lista de tipos de túneis
    for _, validTunnel in ipairs(lista_de_tipos_de_tuneis) do
        if tunnelType == validTunnel then
            return true
        end
    end

    return false
end

-- Decodifica o JSON
--local jsonData = json.decode(jsonContent)
-- jsonData agora contém o conteúdo do arquivo /sdcard/json.txt
local jsonData = decodedData

-- Verifica se o tunnelType existe no JSON.
if jsonData.tunnelType then
    -- Verifica se o tunnelType está na lista de tipos de túneis.
    if TunnelTypeX9(jsonData.tunnelType, lista_de_tipos_de_tuneis) then
        -- O túnel é válido, prossiga com a decodificação.
        gg.toast("🔓 Te peguei, Lionel Richie!")
        Http:New(decodedData)        
    else
        -- Aviso de túnel não encontrado na lista.
        print("Túnel não encontrado na lista - primeiro as primas")
    end
else
    -- Túnel não especificado no JSON, continue com a decodificação.
    print("Campo 'tunnelType' não encontrado no JSON - primeiro as primas")

    -- Continue aqui com a decodificação de outras chaves independentemente do Tunnel Type.

-- Legal, eu vou ser sua tia
Http:New(decodedData)
-- Função para lidar com o túnel específico, se estiver na lista
function handleSpecificTunnel(decodedData, outputFile, tunnelType)
    -- Verifica se decodedData não é nil e se possui a chave tunnelType
    if decodedData and type(decodedData) == "table" and decodedData.tunnelType then
        -- Verifica se o Tunnel Type está na lista conhecida
        if contains(lista_de_tipos_de_tuneis, tunnelType) then
            -- Se está na lista, chama handleTunnel para tratamento específico
            handleTunnel(decodedData, outputFile)
        else
            -- Se não está na lista, chama handleTunnel para tratamento universal
            handleTunnel(decodedData, outputFile)
        end
    else
        -- Se decodedData, não for uma tabela, ou decodedData.tunnelType não existir, trata como um caso universal
        handleTunnel(decodedData, outputFile)
    end
end

-- Legal, eu vou ser sua tia
Http:New(decodedData)
-- Função para lidar com qualquer Tunnel Type
function handleTunnel(decodedData, outputFile)
    -- ... (lógica de tratamento universal)

    -- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
   -- local jsonData = json.decode(jsonContent)
    -- jsonData agora contém o conteúdo do arquivo /sdcard/json.txt
local jsonData = decodedData

    -- Obtém o valor do campo "configTimestamp" e converte para data
local dataFormatada = timestampToData(jsonData.configTimestamp)

-- Verifica se data é válida e a salva
if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
    table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
end

-- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
    table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
    table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
end

-- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
    table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
end

-- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
    table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
end

    -- Adicione mais verificações específicas para cada Tunnel Type aqui

    -- Usa Http:Dec para decodificar a chave "host"
    local hostValue = Http:Dec("host")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if hostValue and type(hostValue) == "string" and hostValue ~= "" and hostValue ~= "N/A" and hostValue ~= nil then
        table.insert(messageParts, "\nSSH: " .. hostValue)
    end

    -- Verifica se a chave "port" existe em decodedData e a adiciona à tabela de partes da mensagem
    if decodedData.port and decodedData.port ~= nil and decodedData.port ~= "N/A" and decodedData.port ~= "" and decodedData.port ~= 0 and decodedData.port ~= "0" then
        table.insert(messageParts, "SSH port: " .. tostring(decodedData.port))
    end

    -- Usa Http:Dec para decodificar a chave "user"
    local userValue = Http:Dec("user")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if userValue and type(userValue) == "string" and userValue ~= "" and userValue ~= "N/A" and userValue ~= nil then
        table.insert(messageParts, "Username: " .. userValue)
    end

    -- Usa Http:Dec para decodificar a chave "password"
    local passwordValue = Http:Dec("password")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if passwordValue and type(passwordValue) == "string" and passwordValue ~= "" and passwordValue ~= "N/A" then
        table.insert(messageParts, "Password: " .. passwordValue)
    end

    -- Usa Http:Dec para decodificar a chave "publicKey"
    local publicKeyValue = Http:Dec("publicKey")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if publicKeyValue and type(publicKeyValue) == "string" and publicKeyValue ~= "" and publicKeyValue ~= "N/A" then
        table.insert(messageParts, "\n\nPublic key: " .. publicKeyValue)
    end

    -- Usa Http:Dec para decodificar a chave "payload"
    local payloadValue = Http:Dec("payload")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if payloadValue and type(payloadValue) == "string" and payloadValue ~= "" and payloadValue ~= "N/A" then
        table.insert(messageParts, "\n\nPayload: " .. payloadValue)
    end

    -- Usa Http:Dec para decodificar a chave "remoteProxy"
    local remoteProxyValue = Http:Dec("remoteProxy")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if remoteProxyValue and type(remoteProxyValue) == "string" and remoteProxyValue ~= "" and remoteProxyValue ~= "N/A" then
        table.insert(messageParts, "\n\nProxy: " .. remoteProxyValue)
    end

    -- Usa Http:Dec para decodificar a chave "remoteProxyUsername"
    local remoteProxyUsernameValue = Http:Dec("remoteProxyUsername")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if remoteProxyUsernameValue and type(remoteProxyUsernameValue) == "string" and remoteProxyUsernameValue ~= "" and remoteProxyUsernameValue ~= "N/A" then
        table.insert(messageParts, "Proxy User: " .. remoteProxyUsernameValue)
    end

    -- Usa Http:Dec para decodificar a chave "remoteProxyPassword"
    local remoteProxyPasswordValue = Http:Dec("remoteProxyPassword")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if remoteProxyPasswordValue and type(remoteProxyPasswordValue) == "string" and remoteProxyPasswordValue ~= "" and remoteProxyPasswordValue ~= "N/A" then
        table.insert(messageParts, "Proxy Password: " .. remoteProxyPasswordValue)
    end
    
    -- Verifica se a chave "sniHostname" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local sniHostnameValue = Http:Dec("sniHostname")
if sniHostnameValue and sniHostnameValue ~= "" and sniHostnameValue ~= nil and sniHostnameValue ~= "N/A" then
    table.insert(messageParts, "\nSNI Hostname: " .. sniHostnameValue)
else
    -- Caso a chave "sniHostname" não exista, adiciona à tabela de partes da mensagem "SNI: facebook.com"
    table.insert(messageParts, "\nSNI: facebook.com")
end
    
    -- Verifica se a chave "htrServerHost" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local htrServerHostValue = Http:Dec("htrServerHost")
if htrServerHostValue and htrServerHostValue ~= "" and htrServerHostValue ~= nil and htrServerHostValue ~= "N/A" then
    table.insert(messageParts, "\nServer: " .. htrServerHostValue)
end

-- Verifica se a chave "htrServerPort" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local htrServerPortValue = Http:Dec("htrServerPort")
if htrServerPortValue and htrServerPortValue ~= "" and htrServerPortValue ~= nil and htrServerPortValue ~= "N/A" and htrServerPortValue ~= 0 and htrServerPortValue ~= "0" then
    table.insert(messageParts, "Server Port: " .. tostring(htrServerPortValue))
end

-- Verifica se a chave "htrProtocol" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local htrProtocolValue = Http:Dec("htrProtocol")
if htrProtocolValue and htrProtocolValue ~= "" and htrProtocolValue ~= nil and htrProtocolValue ~= "N/A" then
    table.insert(messageParts, "\nProtocol: " .. htrProtocolValue)
end

-- Verifica se a chave "htrObfsPassword" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local htrObfsPasswordValue = Http:Dec("htrObfsPassword")
if htrObfsPasswordValue and htrObfsPasswordValue ~= "" and htrObfsPasswordValue ~= nil and htrObfsPasswordValue ~= "N/A" then
    table.insert(messageParts, "\nObfuscation Password: " .. htrObfsPasswordValue)
end

-- Verifica se a chave "htrAuthPayloadType" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local htrAuthPayloadTypeValue = Http:Dec("htrAuthPayloadType")
if htrAuthPayloadTypeValue and htrAuthPayloadTypeValue ~= "" and htrAuthPayloadTypeValue ~= nil and htrAuthPayloadTypeValue ~= "N/A" then
    table.insert(messageParts, "\nAuthentication Payload Type: " .. htrAuthPayloadTypeValue)
end

-- Verifica se a chave "htrAuthPayloadValue" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local htrAuthPayloadValue = Http:Dec("htrAuthPayloadValue")
if htrAuthPayloadValue and htrAuthPayloadValue ~= "" and htrAuthPayloadValue ~= nil and htrAuthPayloadValue ~= "N/A" then
    table.insert(messageParts, "\nAuthentication Payload: " .. htrAuthPayloadValue)
end

-- Verifica se a chave "htrSni" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local htrSniValue = Http:Dec("htrSni")
if htrSniValue and htrSniValue ~= "" and htrSniValue ~= nil and htrSniValue ~= "N/A" then
    table.insert(messageParts, "\nSNI: " .. htrSniValue)
end

-- Verifica se a chave "htrAlpn" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local htrAlpnValue = Http:Dec("htrAlpn")
if htrAlpnValue and htrAlpnValue ~= "" and htrAlpnValue ~= nil and htrAlpnValue ~= "N/A" then
    table.insert(messageParts, "\nALPN: " .. htrAlpnValue)
end

-- Verifica se a chave "htrTlsAllowInsecure" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.htrTlsAllowInsecure and decodedData.htrTlsAllowInsecure ~= "" and decodedData.htrTlsAllowInsecure ~= nil and decodedData.htrTlsAllowInsecure ~= "N/A" then
    table.insert(messageParts, "\nAllow Insecure: " .. decodedData.htrTlsAllowInsecure)
end

-- Verifica se a chave "htrCustomCA" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local htrCustomCAValue = Http:Dec("htrCustomCA")
if htrCustomCAValue and htrCustomCAValue ~= "" and htrCustomCAValue ~= nil and htrCustomCAValue ~= "N/A" then
    table.insert(messageParts, "\nCertificates: " .. htrCustomCAValue)
end

-- Verifica se a chave "htrPortHoppingInterval" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local htrPortHoppingIntervalValue = Http:Dec("htrPortHoppingInterval")
if htrPortHoppingIntervalValue and htrPortHoppingIntervalValue ~= "" and htrPortHoppingIntervalValue ~= nil and htrPortHoppingIntervalValue ~= "N/A" then
    table.insert(messageParts, "\nPort Hopping Interval (second): " .. htrPortHoppingIntervalValue)
end

-- Verifica se a chave "htrMaxUploadSpeed" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local htrMaxUploadSpeedValue = Http:Dec("htrMaxUploadSpeed")
if htrMaxUploadSpeedValue and htrMaxUploadSpeedValue ~= "" and htrMaxUploadSpeedValue ~= nil and htrMaxUploadSpeedValue ~= "N/A" then
    table.insert(messageParts, "\nMax Upload Speed (in Mbps): " .. htrMaxUploadSpeedValue)
end

-- Verifica se a chave "htrMaxDownloadSpeed" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local htrMaxDownloadSpeedValue = Http:Dec("htrMaxDownloadSpeed")
if htrMaxDownloadSpeedValue and htrMaxDownloadSpeedValue ~= "" and htrMaxDownloadSpeedValue ~= nil and htrMaxDownloadSpeedValue ~= "N/A" then
    table.insert(messageParts, "\nMax Download Speed (in Mbps): " .. htrMaxDownloadSpeedValue)
end

-- Verifica se a chave "htrDisableMtuDiscovery" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.htrDisableMtuDiscovery and decodedData.htrDisableMtuDiscovery ~= "" and decodedData.htrDisableMtuDiscovery ~= nil and decodedData.htrDisableMtuDiscovery ~= "N/A" then
    table.insert(messageParts, "\nDisable Path MTU Discovery (RFC 8899): " .. decodedData.htrDisableMtuDiscovery)
end
    
    -- Verifica se a chave "v2rCoreType" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rCoreTypeValue = Http:Dec("v2rCoreType")
if v2rCoreTypeValue and v2rCoreTypeValue ~= "" and v2rCoreTypeValue ~= "none" and v2rCoreTypeValue ~= "N/A" and v2rCoreTypeValue ~= nil then
    table.insert(messageParts, "\nCore: " .. v2rCoreTypeValue)
end

-- Verifica se a chave "v2rFlowType" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rFlowTypeValue = Http:Dec("v2rFlowType")
if v2rFlowTypeValue and v2rFlowTypeValue ~= "" and v2rFlowTypeValue ~= "N/A" and v2rFlowTypeValue ~= nil and v2rFlowTypeValue ~= "none" then
    table.insert(messageParts, "\nFlow: " .. v2rFlowTypeValue)
end

-- Verifica se a chave "v2rAdvancedSettings" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.v2rAdvancedSettings and decodedData.v2rAdvancedSettings ~= "" and decodedData.v2rAdvancedSettings ~= "N/A" and decodedData.v2rAdvancedSettings ~= nil and decodedData.v2rAdvancedSettings ~= "none" then
    table.insert(messageParts, "\nAdvanced Settings: " .. decodedData.v2rAdvancedSettings)
end

-- Verifica se a chave "v2rQuicHeaderType" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rQuicHeaderTypeValue = Http:Dec("v2rQuicHeaderType")
if v2rQuicHeaderTypeValue and v2rQuicHeaderTypeValue ~= "" and v2rQuicHeaderTypeValue ~= nil and v2rQuicHeaderTypeValue ~= "N/A" and v2rQuicHeaderTypeValue ~= "none" then
    table.insert(messageParts, "\nv2rQuicHeaderType: " .. v2rQuicHeaderTypeValue)
end

-- Verifica se a chave "v2rQuicKey" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rQuicKeyValue = Http:Dec("v2rQuicKey")
if v2rQuicKeyValue and v2rQuicKeyValue ~= "" and v2rQuicKeyValue ~= nil and v2rQuicKeyValue ~= "N/A" and v2rQuicKeyValue ~= "none" then
    table.insert(messageParts, "\nv2rQuicKey: " .. v2rQuicKeyValue)
end

-- Verifica se a chave "v2rTcpHeaderType" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rTcpHeaderTypeValue = Http:Dec("v2rTcpHeaderType")
if v2rTcpHeaderTypeValue and v2rTcpHeaderTypeValue ~= "" and v2rTcpHeaderTypeValue ~= nil and v2rTcpHeaderTypeValue ~= "N/A" and v2rTcpHeaderTypeValue ~= "none" then
    table.insert(messageParts, "\nv2rTcpHeaderType: " .. v2rTcpHeaderTypeValue)
end

-- Verifica se a chave "v2rTcpHttpRequest" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rTcpHttpRequestValue = Http:Dec("v2rTcpHttpRequest")
if v2rTcpHttpRequestValue and v2rTcpHttpRequestValue ~= "" and v2rTcpHttpRequestValue ~= nil and v2rTcpHttpRequestValue ~= "N/A" and v2rTcpHttpRequestValue ~= "none" then
    table.insert(messageParts, "\nv2rTcpHttpRequest: " .. v2rTcpHttpRequestValue)
end

-- Verifica se a chave "v2rTleFingerprintType" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rTleFingerprintTypeValue = Http:Dec("v2rTleFingerprintType")
if v2rTleFingerprintTypeValue and v2rTleFingerprintTypeValue ~= "" and v2rTleFingerprintTypeValue ~= nil and v2rTleFingerprintTypeValue ~= "N/A" and v2rTleFingerprintTypeValue ~= "none" then
    table.insert(messageParts, "\nTLS Fingerprint: " .. v2rTleFingerprintTypeValue)
end

-- Verifica se a chave "v2rTleSecurityType" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rTleSecurityTypeValue = Http:Dec("v2rTleSecurityType")
if v2rTleSecurityTypeValue and v2rTleSecurityTypeValue ~= "" and v2rTleSecurityTypeValue ~= nil and v2rTleSecurityTypeValue ~= "N/A" and v2rTleSecurityTypeValue ~= "none" then
    table.insert(messageParts, "\nTipo de segurança Tle: " .. v2rTleSecurityTypeValue)
end

    -- Verifica se a chave "v2rHost" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rHostValue = Http:Dec("v2rHost")
if v2rHostValue and v2rHostValue ~= "" and v2rHostValue ~= "none" and v2rHostValue ~= "N/A" and v2rHostValue ~= nil then
    table.insert(messageParts, "\nServer: " .. v2rHostValue)
end

-- Verifica se a chave "v2rH2Host" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rH2HostValue = Http:Dec("v2rH2Host")
if v2rH2HostValue and v2rH2HostValue ~= "" and v2rH2HostValue ~= nil and v2rH2HostValue ~= "none" and v2rH2HostValue ~= "N/A" then
    table.insert(messageParts, "\nServer: " .. v2rH2HostValue)
end

-- Verifica se a chave "v2rPort" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rPortValue = Http:Dec("v2rPort")
if v2rPortValue and v2rPortValue ~= "" and v2rPortValue ~= "N/A" and v2rPortValue ~= "none" and v2rPortValue ~= nil then
    table.insert(messageParts, "\nServer Port: " .. v2rPortValue)
end

-- Verifica se a chave "v2rNetwork" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rNetworkValue = Http:Dec("v2rNetwork")
if v2rNetworkValue and v2rNetworkValue ~= "" and v2rNetworkValue ~= nil and v2rNetworkValue ~= "none" and v2rNetworkValue ~= "none" and v2rNetworkValue ~= "N/A" then
    table.insert(messageParts, "\nTipo de rede: " .. v2rNetworkValue)
end

-- Verifica se a chave "v2rUserId" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rUserIdValue = Http:Dec("v2rUserId")
if v2rUserIdValue and v2rUserIdValue ~= "" and v2rUserIdValue ~= nil and v2rUserIdValue ~= "N/A" and v2rUserIdValue ~= "none" then
    table.insert(messageParts, "\nUser ID: " .. v2rUserIdValue)
end

-- Verifica se a chave "v2rAlterId" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rAlterIdValue = Http:Dec("v2rAlterId")
if v2rAlterIdValue and v2rAlterIdValue ~= "" and v2rAlterIdValue ~= nil and v2rAlterIdValue ~= "N/A" and v2rAlterIdValue ~= "none" then
    table.insert(messageParts, "\nChange ID: " .. v2rAlterIdValue)
end

-- Verifica se a chave "v2rProtocol" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rProtocolValue = Http:Dec("v2rProtocol")
if v2rProtocolValue and v2rProtocolValue ~= "" and v2rProtocolValue ~= "none" and v2rProtocolValue ~= "N/A" and v2rProtocolValue ~= nil then
    table.insert(messageParts, "\nProtocol: " .. v2rProtocolValue)
end

-- Verifica se a chave "v2rQuicSecurity" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rQuicSecurityValue = Http:Dec("v2rQuicSecurity")
if v2rQuicSecurityValue and v2rQuicSecurityValue ~= "" and v2rQuicSecurityValue ~= nil and v2rQuicSecurityValue ~= "N/A" and v2rQuicSecurityValue ~= "none" then
    table.insert(messageParts, "\nSegurança Rápida: " .. v2rQuicSecurityValue)
end

-- Verifica se a chave "v2rSsSecurity" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rSsSecurityValue = Http:Dec("v2rSsSecurity")
if v2rSsSecurityValue and v2rSsSecurityValue ~= "" and v2rSsSecurityValue ~= nil and v2rSsSecurityValue ~= "N/A" and v2rSsSecurityValue ~= "none" then
    table.insert(messageParts, "\nSs Security: " .. v2rSsSecurityValue)
end

-- Verifica se a chave "v2rVlessSecurity" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rVlessSecurityValue = Http:Dec("v2rVlessSecurity")
if v2rVlessSecurityValue and v2rVlessSecurityValue ~= "" and v2rVlessSecurityValue ~= nil and v2rVlessSecurityValue ~= "none" and v2rVlessSecurityValue ~= "N/A" then
    table.insert(messageParts, "\nVless Security: " .. v2rVlessSecurityValue)
end

-- Verifica se a chave "v2rVmessSecurity" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rVmessSecurityValue = Http:Dec("v2rVmessSecurity")
if v2rVmessSecurityValue and v2rVmessSecurityValue ~= "" and v2rVmessSecurityValue ~= nil and v2rVmessSecurityValue ~= "none" and v2rVmessSecurityValue ~= "N/A" then
    table.insert(messageParts, "\nVmess Security: " .. v2rVmessSecurityValue)
end

-- Verifica se a chave "v2rWsHeader" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rWsHeaderValue = Http:Dec("v2rWsHeader")
if v2rWsHeaderValue and v2rWsHeaderValue ~= "" and v2rWsHeaderValue ~= "none" and v2rWsHeaderValue ~= "N/A" and v2rWsHeaderValue ~= nil then
    table.insert(messageParts, "\nv2rWsHeader: " .. v2rWsHeaderValue)
end

-- Verifica se a chave "v2rTlsSni" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rTlsSniValue = Http:Dec("v2rTlsSni")
if v2rTlsSniValue and v2rTlsSniValue ~= "" and v2rTlsSniValue ~= nil and v2rTlsSniValue ~= "none" and v2rTlsSniValue ~= "N/A" then
    table.insert(messageParts, "\nv2rTlsSNI: " .. v2rTlsSniValue)
end

-- Verifica se a chave "v2rTlsAlpn" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rTlsAlpnValue = Http:Dec("v2rTlsAlpn")
if v2rTlsAlpnValue and v2rTlsAlpnValue ~= "" and v2rTlsAlpnValue ~= nil and v2rTlsAlpnValue ~= "none" and v2rTlsAlpnValue ~= "N/A" then
    table.insert(messageParts, "\nv2rTlsALPN: " .. v2rTlsAlpnValue)
end

-- Verifica se a chave "v2rWsPath" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rWsPathValue = Http:Dec("v2rWsPath")
if v2rWsPathValue and v2rWsPathValue ~= "" and v2rWsPathValue ~= nil and v2rWsPathValue ~= "none" and v2rWsPathValue ~= "N/A" then
    table.insert(messageParts, "\nWebsocket path: " .. v2rWsPathValue)
end

-- Verifica se a chave "v2rH2Path" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rH2PathValue = Http:Dec("v2rH2Path")
if v2rH2PathValue and v2rH2PathValue ~= "" and v2rH2PathValue ~= nil and v2rH2PathValue ~= "none" and v2rH2PathValue ~= "N/A" then
    table.insert(messageParts, "\nCaminho HTTP: " .. v2rH2PathValue)
end

-- Verifica se a chave "v2rTlsAllowInsecure" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.v2rTlsAllowInsecure and decodedData.v2rTlsAllowInsecure ~= "" and decodedData.v2rTlsAllowInsecure ~= "none" and decodedData.v2rTlsAllowInsecure ~= "N/A" and decodedData.v2rTlsAllowInsecure ~= nil then
    table.insert(messageParts, "\nAllow Insecure: " .. decodedData.v2rTlsAllowInsecure)
end

-- Verifica se a chave "v2rKcpMtu" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rKcpMtuValue = Http:Dec("v2rKcpMtu")
if v2rKcpMtuValue and v2rKcpMtuValue ~= "" and v2rKcpMtuValue ~= nil and v2rKcpMtuValue ~= "none" and v2rKcpMtuValue ~= "N/A" then
    table.insert(messageParts, "\nv2rKcpMtu: " .. v2rKcpMtuValue)
end

-- Verifica se a chave "v2rMuxConcurrency" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rMuxConcurrencyValue = Http:Dec("v2rMuxConcurrency")
if v2rMuxConcurrencyValue and v2rMuxConcurrencyValue ~= "" and v2rMuxConcurrencyValue ~= nil and v2rMuxConcurrencyValue ~= "none" and v2rMuxConcurrencyValue ~= "N/A" then
    table.insert(messageParts, "\nConcurrency: " .. v2rMuxConcurrencyValue)
end

-- Verifica se a chave "v2rRawJson" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local v2rRawJsonValue = Http:Dec("v2rRawJson")
if v2rRawJsonValue and v2rRawJsonValue ~= "" and v2rRawJsonValue ~= nil and v2rRawJsonValue ~= "none" and v2rRawJsonValue ~= "N/A" then
    table.insert(messageParts, "\nv2rRawJson: " .. v2rRawJsonValue)
end
    
    -- Verifica se a chave "shadowsocksHost" existe em Http:Dec e a salva
local shadowsocksHostValue = Http:Dec("shadowsocksHost")
if shadowsocksHostValue and shadowsocksHostValue ~= "" and shadowsocksHostValue ~= nil and shadowsocksHostValue ~= "N/A" then
    table.insert(messageParts, "\nShadowsocks Host: " .. shadowsocksHostValue)
end

    -- Verifica se a chave "shadowsocksPort" existe em decodedData e a adiciona à tabela de partes da mensagem
local shadowsocksPortValue = decodedData.shadowsocksPort
if shadowsocksPortValue and shadowsocksPortValue ~= "" and shadowsocksPortValue ~= "0" and shadowsocksPortValue ~= 0 and shadowsocksPortValue ~= "N/A" and shadowsocksPortValue ~= nil then
    table.insert(messageParts, "\nShadowsocks Port: " .. tostring(shadowsocksPortValue))
end

-- Verifica se a chave "shadowsocksPassword" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local shadowsocksPasswordValue = Http:Dec("shadowsocksPassword")
if shadowsocksPasswordValue and shadowsocksPasswordValue ~= "" and shadowsocksPasswordValue ~= "N/A" and shadowsocksPasswordValue ~= nil then
    table.insert(messageParts, "\nShadowsocks Password: " .. shadowsocksPasswordValue)
end

    -- Verifica se a chave "shadowsocksEncryptionMethod" existe em decodedData e a adiciona à tabela de partes da mensagem
local shadowsocksEncryptionMethodValue = decodedData.shadowsocksEncryptionMethod
if shadowsocksEncryptionMethodValue and shadowsocksEncryptionMethodValue ~= "" and shadowsocksEncryptionMethodValue ~= nil and shadowsocksEncryptionMethodValue ~= "N/A" then
    table.insert(messageParts, "\nEncrypt Method: " .. tostring(shadowsocksEncryptionMethodValue))
end
    
    -- Verifica se a chave "httpObfsSettings" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local httpObfsSettingsValue = Http:Dec("httpObfsSettings")
if httpObfsSettingsValue and httpObfsSettingsValue ~= "" and httpObfsSettingsValue ~= "N/A" and httpObfsSettingsValue ~= nil then
    table.insert(messageParts, "\nhttpObfsSettings: " .. httpObfsSettingsValue)
end
    
    -- Adiciona o valor de "dnsttResolverProfile" de decodedData à tabela de partes da mensagem com uma verificação segura
    if decodedData.dnsttResolverProfile and type(decodedData.dnsttResolverProfile) == "string" then
        table.insert(messageParts, "\nDNS Resolver: " .. decodedData.dnsttResolverProfile)
    end

    -- Usa Http:Dec para decodificar a chave "dnsttDnsResolverAddr"
    local dnsttDnsResolverAddrValue = Http:Dec("dnsttDnsResolverAddr")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if dnsttDnsResolverAddrValue and type(dnsttDnsResolverAddrValue) == "string" and dnsttDnsResolverAddrValue ~= "" and dnsttDnsResolverAddrValue ~= "N/A" then
        table.insert(messageParts, "\nDNS Resolver Address: " .. dnsttDnsResolverAddrValue)
    end

    -- Adiciona o valor de "dnsttResolverMode" de decodedData à tabela de partes da mensagem com uma verificação segura
    if decodedData.dnsttResolverMode and type(decodedData.dnsttResolverMode) == "string" then
        table.insert(messageParts, "\nDNSTT Resolver Mode: " .. decodedData.dnsttResolverMode)
    end

    -- Usa Http:Dec para decodificar a chave "dnsttNameserver"
    local dnsttNameserverValue = Http:Dec("dnsttNameserver")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if dnsttNameserverValue and type(dnsttNameserverValue) == "string" and dnsttNameserverValue ~= "" and dnsttNameserverValue ~= "N/A" then
        table.insert(messageParts, "\nDNSTT Nameserver: " .. dnsttNameserverValue)
    end

    -- Usa Http:Dec para decodificar a chave "dnsttPublicKey"
    local dnsttPublicKeyValue = Http:Dec("dnsttPublicKey")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if dnsttPublicKeyValue and type(dnsttPublicKeyValue) == "string" and dnsttPublicKeyValue ~= "" and dnsttPublicKeyValue ~= "N/A" then
        table.insert(messageParts, "\nDNSTT public key: " .. dnsttPublicKeyValue)
    end

    -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o "Tunnel Type" à mensagem
    table.insert(messageParts, "\n\nTunnel Type: " .. decodedData.tunnelType)

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com qualquer Tunnel Type
handleTunnel(decodedData, outputFile)
    
-- end

-- Verifica se um elemento está presente em uma tabela
function contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
end

-- Continue aqui com a decodificação de outros dados no JSON, mesmo sem o Tunnel Type.

  -- mensagem descrição Tunnel Type
  message = tunnelDescription  

-- Função para lidar com o túnel "http_obfs_shadowsocks"
function handleHttpObfsShadowsocks(decodedData, outputFile)

-- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}
    
    -- Verifica se messageParts é uma tabela válida, se não, cria uma nova tabela
    if not messageParts then
        messageParts = {}
    end
    
    -- Resto da função com a coleta e salvamento de dados...

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
    --local jsonData = json.decode(jsonContent)
-- jsonData agora contém o conteúdo do arquivo /sdcard/json.txt
local jsonData = decodedData

-- Obtém o valor do campo "configTimestamp" e converte para data
local dataFormatada = timestampToData(jsonData.configTimestamp)

-- Verifica se data é válida e a salva
if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
    table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
end

-- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
    table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
    table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
end

-- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
    table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
end

-- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
    table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
end

    -- Verifica se a chave "shadowsocksHost" existe em Http:Dec e a salva
local shadowsocksHostValue = Http:Dec("shadowsocksHost")
if shadowsocksHostValue and shadowsocksHostValue ~= "" and shadowsocksHostValue ~= nil and shadowsocksHostValue ~= "N/A" then
    table.insert(messageParts, "\nShadowsocks Host: " .. shadowsocksHostValue)
end


    -- Verifica se a chave "shadowsocksPort" existe em decodedData e a adiciona à tabela de partes da mensagem
local shadowsocksPortValue = decodedData.shadowsocksPort
if shadowsocksPortValue and shadowsocksPortValue ~= "" and shadowsocksPortValue ~= "0" and shadowsocksPortValue ~= 0 and shadowsocksPortValue ~= "N/A" and shadowsocksPortValue ~= nil then
    table.insert(messageParts, "\nShadowsocks Port: " .. tostring(shadowsocksPortValue))
end

-- Verifica se a chave "shadowsocksPassword" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local shadowsocksPasswordValue = Http:Dec("shadowsocksPassword")
if shadowsocksPasswordValue and shadowsocksPasswordValue ~= "" and shadowsocksPasswordValue ~= "N/A" and shadowsocksPasswordValue ~= nil then
    table.insert(messageParts, "\nShadowsocks Password: " .. shadowsocksPasswordValue)
end

-- Verifica se a chave "shadowsocksEncryptionMethod" existe em decodedData e a adiciona à tabela de partes da mensagem
local shadowsocksEncryptionMethodValue = decodedData.shadowsocksEncryptionMethod
if shadowsocksEncryptionMethodValue and shadowsocksEncryptionMethodValue ~= "" and shadowsocksEncryptionMethodValue ~= nil and shadowsocksEncryptionMethodValue ~= "N/A" then
    table.insert(messageParts, "\nEncrypt Method: " .. tostring(shadowsocksEncryptionMethodValue))
end

-- Verifica se a chave "httpObfsSettings" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local httpObfsSettingsValue = Http:Dec("httpObfsSettings")
if httpObfsSettingsValue and httpObfsSettingsValue ~= "" and httpObfsSettingsValue ~= "N/A" and httpObfsSettingsValue ~= nil then
    table.insert(messageParts, "\nhttpObfsSettings: " .. httpObfsSettingsValue)
end
        
        -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o restante do conteúdo à tabela de partes da mensagem

    -- Agora, adicione o "Tunnel Type" à mensagem com duas quebras de linha
    table.insert(messageParts, "\n\nTunnel Type: " .. getTunnelDescription(decodedData.tunnelType))

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com http_obfs_shadowsocks
if decodedData.tunnelType == "http_obfs_shadowsocks" then
    -- Use outputFile como o terceiro argumento ao chamar a função handleHttpObfsShadowsocks
    handleHttpObfsShadowsocks(decodedData, outputFile)
end

-- Função para lidar com o túnel "tls_obfs_shadowsocks"
function handleTlsObfsShadowsocks(decodedData, outputFile)

-- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}
    
    -- Verifica se messageParts é uma tabela válida, se não, cria uma nova tabela
    if not messageParts then
        messageParts = {}
    end
    
    -- Resto da função com a coleta e salvamento de dados...

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
    --local jsonData = json.decode(jsonContent)
-- jsonData agora contém o conteúdo do arquivo /sdcard/json.txt
local jsonData = decodedData

-- Obtém o valor do campo "configTimestamp" e converte para data
local dataFormatada = timestampToData(jsonData.configTimestamp)

-- Verifica se data é válida e a salva
if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
    table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
end

-- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
    table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
    table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
end

-- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
    table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
end

-- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
    table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
end

    -- Verifica se a chave "shadowsocksHost" existe em Http:Dec e a salva
local shadowsocksHostValue = Http:Dec("shadowsocksHost")
if shadowsocksHostValue and shadowsocksHostValue ~= "" and shadowsocksHostValue ~= nil and shadowsocksHostValue ~= "N/A" then
    table.insert(messageParts, "\nShadowsocks Host: " .. shadowsocksHostValue)
end

    -- Verifica se a chave "shadowsocksPort" existe em decodedData e a adiciona à tabela de partes da mensagem
local shadowsocksPortValue = decodedData.shadowsocksPort
if shadowsocksPortValue and shadowsocksPortValue ~= "" and shadowsocksPortValue ~= "0" and shadowsocksPortValue ~= 0 and shadowsocksPortValue ~= "N/A" and shadowsocksPortValue ~= nil then
    table.insert(messageParts, "\nShadowsocks Port: " .. tostring(shadowsocksPortValue))
end

-- Verifica se a chave "shadowsocksPassword" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local shadowsocksPasswordValue = Http:Dec("shadowsocksPassword")
if shadowsocksPasswordValue and shadowsocksPasswordValue ~= "" and shadowsocksPasswordValue ~= "N/A" and shadowsocksPasswordValue ~= nil then
    table.insert(messageParts, "\nShadowsocks Password: " .. shadowsocksPasswordValue)
end

    -- Verifica se a chave "shadowsocksEncryptionMethod" existe em decodedData e a adiciona à tabela de partes da mensagem
local shadowsocksEncryptionMethodValue = decodedData.shadowsocksEncryptionMethod
if shadowsocksEncryptionMethodValue and shadowsocksEncryptionMethodValue ~= "" and shadowsocksEncryptionMethodValue ~= nil and shadowsocksEncryptionMethodValue ~= "N/A" then
    table.insert(messageParts, "\nEncrypt Method: " .. tostring(shadowsocksEncryptionMethodValue))
end

-- Verifica se a chave "sniHostname" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local sniHostnameValue = Http:Dec("sniHostname")
if sniHostnameValue and sniHostnameValue ~= "" and sniHostnameValue ~= nil and sniHostnameValue ~= "N/A" then
    table.insert(messageParts, "\nSNI Hostname: " .. sniHostnameValue)
else
    -- Caso a chave "sniHostname" não exista, adiciona à tabela de partes da mensagem "SNI: facebook.com"
    table.insert(messageParts, "\nSNI: facebook.com")
end

    -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o restante do conteúdo à tabela de partes da mensagem

    -- Agora, adicione o "Tunnel Type" à mensagem com duas quebras de linha
    table.insert(messageParts, "\n\nTunnel Type: " .. getTunnelDescription(decodedData.tunnelType))

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com tls_obfs_shadowsocks
if decodedData.tunnelType == "tls_obfs_shadowsocks" then
    handleTlsObfsShadowsocks(decodedData, outputFile)
end

-- Função para lidar com o túnel "direct_shadowsocks"
function handleDirectShadowsocks(decodedData, outputFile)

-- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}
    
    -- Verifica se messageParts é uma tabela válida, se não, cria uma nova tabela
    if not messageParts then
        messageParts = {}
    end
    
    -- Resto da função com a coleta e salvamento de dados...

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
    --local jsonData = json.decode(jsonContent)
-- jsonData agora contém o conteúdo do arquivo /sdcard/json.txt
local jsonData = decodedData

-- Obtém o valor do campo "configTimestamp" e converte para data
local dataFormatada = timestampToData(jsonData.configTimestamp)

-- Verifica se data é válida e a salva
if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
    table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
end

-- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
    table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
    table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
end

-- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
    table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
end

-- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
    table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
end

    -- Verifica se a chave "shadowsocksHost" existe em Http:Dec e a salva
local shadowsocksHostValue = Http:Dec("shadowsocksHost")
if shadowsocksHostValue and shadowsocksHostValue ~= "" and shadowsocksHostValue ~= nil and shadowsocksHostValue ~= "N/A" then
    table.insert(messageParts, "\nShadowsocks Host: " .. shadowsocksHostValue)
end

    -- Verifica se a chave "shadowsocksPort" existe em decodedData e a adiciona à tabela de partes da mensagem
local shadowsocksPortValue = decodedData.shadowsocksPort
if shadowsocksPortValue and shadowsocksPortValue ~= "" and shadowsocksPortValue ~= "0" and shadowsocksPortValue ~= 0 and shadowsocksPortValue ~= "N/A" and shadowsocksPortValue ~= nil then
    table.insert(messageParts, "\nShadowsocks Port: " .. tostring(shadowsocksPortValue))
end

-- Verifica se a chave "shadowsocksPassword" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local shadowsocksPasswordValue = Http:Dec("shadowsocksPassword")
if shadowsocksPasswordValue and shadowsocksPasswordValue ~= "" and shadowsocksPasswordValue ~= "N/A" and shadowsocksPasswordValue ~= nil then
    table.insert(messageParts, "\nShadowsocks Password: " .. shadowsocksPasswordValue)
end

-- Verifica se a chave "shadowsocksEncryptionMethod" existe em decodedData e a adiciona à tabela de partes da mensagem
local shadowsocksEncryptionMethodValue = decodedData.shadowsocksEncryptionMethod
if shadowsocksEncryptionMethodValue and shadowsocksEncryptionMethodValue ~= "" and shadowsocksEncryptionMethodValue ~= nil and shadowsocksEncryptionMethodValue ~= "N/A" then
    table.insert(messageParts, "\nEncrypt Method: " .. tostring(shadowsocksEncryptionMethodValue))
end
    
    -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o restante do conteúdo à tabela de partes da mensagem

    -- Agora, adicione o "Tunnel Type" à mensagem com duas quebras de linha
    table.insert(messageParts, "\n\nTunnel Type: " .. getTunnelDescription(decodedData.tunnelType))

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com direct_shadowsocks
if decodedData.tunnelType == "direct_shadowsocks" then
    handleDirectShadowsocks(decodedData, outputFile)
end

-- Função para lidar com o túnel "ssl_shadowsocks"
function handleSslShadowsocks(decodedData, outputFile)

-- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}
    
    -- Verifica se messageParts é uma tabela válida, se não, cria uma nova tabela
    if not messageParts then
        messageParts = {}
    end
    
    -- Resto da função com a coleta e salvamento de dados...

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
    --local jsonData = json.decode(jsonContent)
-- jsonData agora contém o conteúdo do arquivo /sdcard/json.txt
local jsonData = decodedData

-- Obtém o valor do campo "configTimestamp" e converte para data
local dataFormatada = timestampToData(jsonData.configTimestamp)

-- Verifica se data é válida e a salva
if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
    table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
end

-- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
    table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
    table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
end

-- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
    table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
end

-- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
    table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
end

    -- Verifica se a chave "shadowsocksHost" existe em Http:Dec e a salva
local shadowsocksHostValue = Http:Dec("shadowsocksHost")
if shadowsocksHostValue and shadowsocksHostValue ~= "" and shadowsocksHostValue ~= nil and shadowsocksHostValue ~= "N/A" then
    table.insert(messageParts, "\nShadowsocks Host: " .. shadowsocksHostValue)
end

    -- Verifica se a chave "shadowsocksPort" existe em decodedData e a adiciona à tabela de partes da mensagem
local shadowsocksPortValue = decodedData.shadowsocksPort
if shadowsocksPortValue and shadowsocksPortValue ~= "" and shadowsocksPortValue ~= "0" and shadowsocksPortValue ~= 0 and shadowsocksPortValue ~= "N/A" and shadowsocksPortValue ~= nil then
    table.insert(messageParts, "\nShadowsocks Port: " .. tostring(shadowsocksPortValue))
end

-- Verifica se a chave "shadowsocksPassword" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local shadowsocksPasswordValue = Http:Dec("shadowsocksPassword")
if shadowsocksPasswordValue and shadowsocksPasswordValue ~= "" and shadowsocksPasswordValue ~= "N/A" and shadowsocksPasswordValue ~= nil then
    table.insert(messageParts, "\nShadowsocks Password: " .. shadowsocksPasswordValue)
end

-- Verifica se a chave "shadowsocksEncryptionMethod" existe em decodedData e a adiciona à tabela de partes da mensagem
local shadowsocksEncryptionMethodValue = decodedData.shadowsocksEncryptionMethod
if shadowsocksEncryptionMethodValue and shadowsocksEncryptionMethodValue ~= "" and shadowsocksEncryptionMethodValue ~= nil and shadowsocksEncryptionMethodValue ~= "N/A" then
    table.insert(messageParts, "\nEncrypt Method: " .. tostring(shadowsocksEncryptionMethodValue))
end

    -- Verifica se a chave "sniHostname" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local sniHostnameValue = Http:Dec("sniHostname")
if sniHostnameValue and sniHostnameValue ~= "" and sniHostnameValue ~= nil and sniHostnameValue ~= "N/A" then
    table.insert(messageParts, "\nSNI Hostname: " .. sniHostnameValue)
else
    -- Caso a chave "sniHostname" não exista, adiciona à tabela de partes da mensagem "SNI: facebook.com"
    table.insert(messageParts, "\nSNI: facebook.com")
end
    
    -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o restante do conteúdo à tabela de partes da mensagem

    -- Agora, adicione o "Tunnel Type" à mensagem com duas quebras de linha
    table.insert(messageParts, "\n\nTunnel Type: " .. getTunnelDescription(decodedData.tunnelType))

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com ssl_shadowsocks
if decodedData.tunnelType == "ssl_shadowsocks" then
    handleSslShadowsocks(decodedData, outputFile)
end

-- Função para lidar com o túnel "direct_v2r"
function handleDirectV2r(decodedData, outputFile)

-- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}
    
    -- Verifica se messageParts é uma tabela válida, se não, cria uma nova tabela
    if not messageParts then
        messageParts = {}
    end
    
    -- Resto da função com a coleta e salvamento de dados...

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
    --local jsonData = json.decode(jsonContent)
-- jsonData agora contém o conteúdo do arquivo /sdcard/json.txt
local jsonData = decodedData

-- Obtém o valor do campo "configTimestamp" e converte para data
local dataFormatada = timestampToData(jsonData.configTimestamp)

-- Verifica se data é válida e a salva
if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
    table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
end

-- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
    table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
    table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
end

-- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
    table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
end

-- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
    table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
end

-- Função para verificar e adicionar à tabela de partes da mensagem
local function addToMessageParts(label, value)
    if value and ((type(value) == "string" or type(value) == "number") and value ~= "N/A") then
        table.insert(messageParts, "\n" .. label .. ": " .. tostring(value))
    end
end

-- Verifica e adiciona à tabela de partes da mensagem usando Http:Dec e decodedData
addToMessageParts("Core", Http:Dec("v2rCoreType"))
addToMessageParts("Flow", Http:Dec("v2rFlowType"))
addToMessageParts("Advanced Settings", decodedData.v2rAdvancedSettings)
addToMessageParts("v2rQuicHeaderType", Http:Dec("v2rQuicHeaderType"))
addToMessageParts("v2rQuicKey", Http:Dec("v2rQuicKey"))
addToMessageParts("v2rTcpHeaderType", Http:Dec("v2rTcpHeaderType"))
addToMessageParts("v2rTcpHttpRequest", Http:Dec("v2rTcpHttpRequest"))
addToMessageParts("TLS Fingerprint", Http:Dec("v2rTleFingerprintType"))
addToMessageParts("v2rTleSecurityType", Http:Dec("v2rTleSecurityType"))
addToMessageParts("Server (v2rHost)", Http:Dec("v2rHost"))
addToMessageParts("Server (v2rH2Host)", Http:Dec("v2rH2Host"))
addToMessageParts("Server Port", Http:Dec("v2rPort"))
addToMessageParts("Network type", Http:Dec("v2rNetwork"))
addToMessageParts("User ID", Http:Dec("v2rUserId"))
addToMessageParts("Change ID", Http:Dec("v2rAlterId"))
addToMessageParts("Protocol", Http:Dec("v2rProtocol"))
addToMessageParts("Quick Security", Http:Dec("v2rQuicSecurity"))
addToMessageParts("Ss Security", Http:Dec("v2rSsSecurity"))
addToMessageParts("Vless Security", Http:Dec("v2rVlessSecurity"))
addToMessageParts("Vmess Security", Http:Dec("v2rVmessSecurity"))
addToMessageParts("v2rWsHeader", Http:Dec("v2rWsHeader"))
addToMessageParts("v2rTlsSNI", Http:Dec("v2rTlsSni"))
addToMessageParts("v2rTlsALPN", Http:Dec("v2rTlsAlpn"))
addToMessageParts("v2rWsPath", Http:Dec("v2rWsPath"))
addToMessageParts("v2rH2Path", Http:Dec("v2rH2Path"))
addToMessageParts("Allow Insecure", decodedData.v2rTlsAllowInsecure)
addToMessageParts("v2rKcpMtu", Http:Dec("v2rKcpMtu"))
addToMessageParts("Concurrency", Http:Dec("v2rMuxConcurrency"))
addToMessageParts("v2rRawJson", Http:Dec("v2rRawJson"))

-- Exibe a tabela de partes da mensagem
for _, part in ipairs(messageParts) do
    -- Aqui você pode fazer o que for necessário com cada parte da mensagem
    -- Por exemplo, imprimir ou usar em outro lugar da sua diversão
    gg.toast(part)
end

-- Exibe uma mensagem se nenhuma parte válida foi encontrada
if #messageParts == 0 then
    print("Primeiro as primas: Pai não encontrado")
end
 
    -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o restante do conteúdo à tabela de partes da mensagem

    -- Agora, adicione o "Tunnel Type" à mensagem com duas quebras de linha
    table.insert(messageParts, "\n\nTunnel Type: " .. getTunnelDescription(decodedData.tunnelType))

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com direct_v2r
if decodedData.tunnelType == "direct_v2r" then
    handleDirectV2r(decodedData, outputFile)
end

-- Função para lidar com o túnel "hysteria"
function handleHysteria(decodedData, outputFile)

-- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}
    
    -- Verifica se messageParts é uma tabela válida, se não, cria uma nova tabela
    if not messageParts then
        messageParts = {}
    end
    
    -- Resto da função com a coleta e salvamento de dados...

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
    --local jsonData = json.decode(jsonContent)
-- jsonData agora contém o conteúdo do arquivo /sdcard/json.txt
local jsonData = decodedData

-- Obtém o valor do campo "configTimestamp" e converte para data
local dataFormatada = timestampToData(jsonData.configTimestamp)

-- Verifica se data é válida e a salva
if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
    table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
end

-- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
    table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
    table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
end

-- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
    table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
end

-- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
    table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
end

-- Verifica se a chave "htrServerHost" existe em Http:Dec e a salva
local htrServerHostValue = Http:Dec("htrServerHost")
if htrServerHostValue and htrServerHostValue ~= "" and htrServerHostValue ~= nil and htrServerHostValue ~= "N/A" then
    table.insert(messageParts, "\nServer: " .. htrServerHostValue)
end

-- Verifica se a chave "htrServerPort" existe em Http:Dec e a salva
local htrServerPortValue = Http:Dec("htrServerPort")
if htrServerPortValue and htrServerPortValue ~= "" and htrServerPortValue ~= nil and htrServerPortValue ~= "N/A" and htrServerPortValue ~= 0 then
    table.insert(messageParts, "Server Port: " .. htrServerPortValue)
end

-- Verifica se a chave "htrProtocol" existe em Http:Dec e a salva
local htrProtocolValue = Http:Dec("htrProtocol")
if htrProtocolValue and htrProtocolValue ~= "" and htrProtocolValue ~= nil and htrProtocolValue ~= "N/A" then
    table.insert(messageParts, "\nProtocol: " .. htrProtocolValue)
end

-- Verifica se a chave "htrObfsPassword" existe em Http:Dec e a salva
local htrObfsPasswordValue = Http:Dec("htrObfsPassword")
if htrObfsPasswordValue and htrObfsPasswordValue ~= "" and htrObfsPasswordValue ~= nil and htrObfsPasswordValue ~= "N/A" then
    table.insert(messageParts, "\nObfuscation Password: " .. htrObfsPasswordValue)
end

-- Verifica se a chave "htrAuthPayloadType" existe em Http:Dec e a salva
local htrAuthPayloadTypeValue = Http:Dec("htrAuthPayloadType")
if htrAuthPayloadTypeValue and htrAuthPayloadTypeValue ~= "" and htrAuthPayloadTypeValue ~= nil and htrAuthPayloadTypeValue ~= "N/A" then
    table.insert(messageParts, "\nAuthentication Payload Type: " .. htrAuthPayloadTypeValue)
end

-- Verifica se a chave "htrAuthPayloadValue" existe em Http:Dec e a salva
local htrAuthPayloadValue = Http:Dec("htrAuthPayloadValue")
if htrAuthPayloadValue and htrAuthPayloadValue ~= "" and htrAuthPayloadValue ~= nil and htrAuthPayloadValue ~= "N/A" then
    table.insert(messageParts, "\nAuthentication Payload: " .. htrAuthPayloadValue)
end

-- Verifica se a chave "htrSni" existe em Http:Dec e a salva
local htrSniValue = Http:Dec("htrSni")
if htrSniValue and htrSniValue ~= "" and htrSniValue ~= nil and htrSniValue ~= "N/A" then
    table.insert(messageParts, "\nSNI: " .. htrSniValue)
end

-- Verifica se a chave "htrAlpn" existe em Http:Dec e a salva
local htrAlpnValue = Http:Dec("htrAlpn")
if htrAlpnValue and htrAlpnValue ~= "" and htrAlpnValue ~= nil and htrAlpnValue ~= "N/A" then
    table.insert(messageParts, "\nALPN: " .. htrAlpnValue)
end

-- Verifica se a chave "htrTlsAllowInsecure" existe em decodedData e a salva
if decodedData.htrTlsAllowInsecure and decodedData.htrTlsAllowInsecure ~= "" and decodedData.htrTlsAllowInsecure ~= nil and decodedData.htrTlsAllowInsecure ~= "N/A" then
    table.insert(messageParts, "\nAllow Insecure: " .. tostring(decodedData.htrTlsAllowInsecure))
end

-- Verifica se a chave "htrCustomCA" existe em Http:Dec e a salva
local htrCustomCAValue = Http:Dec("htrCustomCA")
if htrCustomCAValue and htrCustomCAValue ~= "" and htrCustomCAValue ~= nil and htrCustomCAValue ~= "N/A" then
    table.insert(messageParts, "\nCertificates: " .. htrCustomCAValue)
end

-- Verifica se a chave "htrPortHoppingInterval" existe em Http:Dec e a salva
local htrPortHoppingIntervalValue = Http:Dec("htrPortHoppingInterval")
if htrPortHoppingIntervalValue and htrPortHoppingIntervalValue ~= "" and htrPortHoppingIntervalValue ~= nil and htrPortHoppingIntervalValue ~= "N/A" then
    table.insert(messageParts, "\nPort Hopping Interval (second): " .. htrPortHoppingIntervalValue)
end

-- Verifica se a chave "htrMaxUploadSpeed" existe em Http:Dec e a salva
local htrMaxUploadSpeedValue = Http:Dec("htrMaxUploadSpeed")
if htrMaxUploadSpeedValue and htrMaxUploadSpeedValue ~= "" and htrMaxUploadSpeedValue ~= nil and htrMaxUploadSpeedValue ~= "N/A" then
    table.insert(messageParts, "\nMax Upload Speed (in Mbps): " .. htrMaxUploadSpeedValue)
end

-- Verifica se a chave "htrMaxDownloadSpeed" existe em Http:Dec e a salva
local htrMaxDownloadSpeedValue = Http:Dec("htrMaxDownloadSpeed")
if htrMaxDownloadSpeedValue and htrMaxDownloadSpeedValue ~= "" and htrMaxDownloadSpeedValue ~= nil and htrMaxDownloadSpeedValue ~= "N/A" then
    table.insert(messageParts, "\nMax Download Speed (in Mbps): " .. htrMaxDownloadSpeedValue)
end

-- Verifica se a chave "htrDisableMtuDiscovery" existe em decodedData e a salva
if decodedData.htrDisableMtuDiscovery and decodedData.htrDisableMtuDiscovery ~= "" and decodedData.htrDisableMtuDiscovery ~= nil and decodedData.htrDisableMtuDiscovery ~= "N/A" then
    table.insert(messageParts, "\nDisable Path MTU Discovery (RFC 8899): " .. tostring(decodedData.htrDisableMtuDiscovery))
end

    -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o restante do conteúdo à tabela de partes da mensagem

    -- Agora, adicione o "Tunnel Type" à mensagem com duas quebras de linha
    table.insert(messageParts, "\n\nTunnel Type: " .. getTunnelDescription(decodedData.tunnelType))

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com hysteria
if decodedData.tunnelType == "hysteria" then
    handleHysteria(decodedData, outputFile)
end

-- Função para lidar com o túnel "dnstt_ssh"
function handleDnsttSsh(decodedData, outputFile)

    -- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}
    
    -- Verifica se messageParts é uma tabela válida, se não, cria uma nova tabela
    if not messageParts then
        messageParts = {}
    end
    
    -- Resto da função com a coleta e salvamento de dados...

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
    --local jsonData = json.decode(jsonContent)
-- jsonData agora contém o conteúdo do arquivo /sdcard/json.txt
local jsonData = decodedData

-- Obtém o valor do campo "configTimestamp" e converte para data
local dataFormatada = timestampToData(jsonData.configTimestamp)

-- Verifica se data é válida e a salva
if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
    table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
end

-- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
    table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
    table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
end

-- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
    table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
end

-- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
    table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
end

-- Adiciona o valor de "dnsttResolverProfile" de decodedData à tabela de partes da mensagem com uma verificação segura
    if decodedData.dnsttResolverProfile and type(decodedData.dnsttResolverProfile) == "string" then
        table.insert(messageParts, "\nDNS Resolver: " .. decodedData.dnsttResolverProfile)
    end

    -- Usa Http:Dec para decodificar a chave "dnsttDnsResolverAddr"
    local dnsttDnsResolverAddrValue = Http:Dec("dnsttDnsResolverAddr")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if dnsttDnsResolverAddrValue and type(dnsttDnsResolverAddrValue) == "string" and dnsttDnsResolverAddrValue ~= "" and dnsttDnsResolverAddrValue ~= "N/A" then
        table.insert(messageParts, "\nDNS Resolver Address: " .. dnsttDnsResolverAddrValue)
    end

    -- Adiciona o valor de "dnsttResolverMode" de decodedData à tabela de partes da mensagem com uma verificação segura
    if decodedData.dnsttResolverMode and type(decodedData.dnsttResolverMode) == "string" then
        table.insert(messageParts, "\nDNSTT Resolver Mode: " .. decodedData.dnsttResolverMode)
    end

    -- Usa Http:Dec para decodificar a chave "dnsttNameserver"
    local dnsttNameserverValue = Http:Dec("dnsttNameserver")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if dnsttNameserverValue and type(dnsttNameserverValue) == "string" and dnsttNameserverValue ~= "" and dnsttNameserverValue ~= "N/A" then
        table.insert(messageParts, "\nDNSTT Nameserver: " .. dnsttNameserverValue)
    end

    -- Usa Http:Dec para decodificar a chave "dnsttPublicKey"
    local dnsttPublicKeyValue = Http:Dec("dnsttPublicKey")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if dnsttPublicKeyValue and type(dnsttPublicKeyValue) == "string" and dnsttPublicKeyValue ~= "" and dnsttPublicKeyValue ~= "N/A" then
        table.insert(messageParts, "\nDNSTT public key: " .. dnsttPublicKeyValue)
    end

    -- Usa Http:Dec para decodificar a chave "host"
    local hostValue = Http:Dec("host")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if hostValue and type(hostValue) == "string" and hostValue ~= "" and hostValue ~= "N/A" then
        table.insert(messageParts, "\nSSH: " .. hostValue)
    end

    -- Verifica se a chave "port" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.port and decodedData.port ~= 0 and decodedData.port ~= "0" and ((type(decodedData.port) == "string" or type(decodedData.port) == "number") and decodedData.port ~= "N/A") then
    table.insert(messageParts, "SSH port: " .. tostring(decodedData.port))
end

    -- Usa Http:Dec para decodificar a chave "user"
    local userValue = Http:Dec("user")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if userValue and type(userValue) == "string" and userValue ~= "" and userValue ~= "N/A" then
        table.insert(messageParts, "Username: " .. userValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "password"
    local passwordValue = Http:Dec("password")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if passwordValue and type(passwordValue) == "string" and passwordValue ~= "" and passwordValue ~= "N/A" then
        table.insert(messageParts, "Password: " .. passwordValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "publicKey"
    local publicKeyValue = Http:Dec("publicKey")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if publicKeyValue and type(publicKeyValue) == "string" and publicKeyValue ~= "" and publicKeyValue ~= "N/A" then
        table.insert(messageParts, "\n\nPublic key: " .. publicKeyValue)
    end

    -- Adicione o restante do conteúdo à tabela de partes da mensagem

    -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o restante do conteúdo à tabela de partes da mensagem

    -- Agora, adicione o "Tunnel Type" à mensagem com duas quebras de linha
    table.insert(messageParts, "\n\nTunnel Type: " .. getTunnelDescription(decodedData.tunnelType))

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com dnstt_ssh
if decodedData.tunnelType == "dnstt_ssh" then
    handleDnsttSsh(decodedData, outputFile)
end

-- Função para lidar com o túnel "direct_ssh"
function handleDirectSsh(decodedData, outputFile)

-- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}
    
    -- Verifica se messageParts é uma tabela válida, se não, cria uma nova tabela
    if not messageParts then
        messageParts = {}
    end
    
    -- Resto da função com a coleta e salvamento de dados...

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
    --local jsonData = json.decode(jsonContent)
-- jsonData agora contém o conteúdo do arquivo /sdcard/json.txt
local jsonData = decodedData

-- Obtém o valor do campo "configTimestamp" e converte para data
local dataFormatada = timestampToData(jsonData.configTimestamp)

-- Verifica se data é válida e a salva
if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
    table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
end

-- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
    table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
    table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
end

-- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
    table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
end

-- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
    table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
end
    
    -- Usa Http:Dec para decodificar a chave "host"
    local hostValue = Http:Dec("host")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if hostValue and type(hostValue) == "string" and hostValue ~= "" and hostValue ~= "N/A" then
        table.insert(messageParts, "\nSSH: " .. hostValue)
    end

    -- Verifica se a chave "port" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.port and decodedData.port ~= 0 and decodedData.port ~= "0" and ((type(decodedData.port) == "string" or type(decodedData.port) == "number") and decodedData.port ~= "N/A") then
    table.insert(messageParts, "SSH port: " .. tostring(decodedData.port))
end

    -- Usa Http:Dec para decodificar a chave "user"
    local userValue = Http:Dec("user")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if userValue and type(userValue) == "string" and userValue ~= "" and userValue ~= "N/A" then
        table.insert(messageParts, "Username: " .. userValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "password"
    local passwordValue = Http:Dec("password")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if passwordValue and type(passwordValue) == "string" and passwordValue ~= "" and passwordValue ~= "N/A" then
        table.insert(messageParts, "Password: " .. passwordValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "publicKey"
    local publicKeyValue = Http:Dec("publicKey")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if publicKeyValue and type(publicKeyValue) == "string" and publicKeyValue ~= "" and publicKeyValue ~= "N/A" then
        table.insert(messageParts, "\n\nPublic key: " .. publicKeyValue)
    end

-- Adicione o restante do conteúdo à tabela de partes da mensagem

    -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o restante do conteúdo à tabela de partes da mensagem

    -- Agora, adicione o "Tunnel Type" à mensagem com duas quebras de linha
    table.insert(messageParts, "\n\nTunnel Type: " .. getTunnelDescription(decodedData.tunnelType))

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com direct_ssh
if decodedData.tunnelType == "direct_ssh" then
    handleDirectSsh(decodedData, outputFile)
end

-- Função para lidar com o túnel "direct_payload_ssh"
function handleDirectPayloadSsh(decodedData, outputFile)

-- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}
    
    -- Verifica se messageParts é uma tabela válida, se não, cria uma nova tabela
    if not messageParts then
        messageParts = {}
    end
    
    -- Resto da função com a coleta e salvamento de dados...

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
    --local jsonData = json.decode(jsonContent)
-- jsonData agora contém o conteúdo do arquivo /sdcard/json.txt
local jsonData = decodedData

-- Obtém o valor do campo "configTimestamp" e converte para data
local dataFormatada = timestampToData(jsonData.configTimestamp)

-- Verifica se data é válida e a salva
if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
    table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
end

-- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
    table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
    table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
end

-- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
    table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
end

-- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
    table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
end
    
    -- Usa Http:Dec para decodificar a chave "host"
    local hostValue = Http:Dec("host")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if hostValue and type(hostValue) == "string" and hostValue ~= "" and hostValue ~= "N/A" then
        table.insert(messageParts, "\nSSH: " .. hostValue)
    end

    -- Verifica se a chave "port" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.port and decodedData.port ~= 0 and decodedData.port ~= "0" and ((type(decodedData.port) == "string" or type(decodedData.port) == "number") and decodedData.port ~= "N/A") then
    table.insert(messageParts, "SSH port: " .. tostring(decodedData.port))
end

    -- Usa Http:Dec para decodificar a chave "user"
    local userValue = Http:Dec("user")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if userValue and type(userValue) == "string" and userValue ~= "" and userValue ~= "N/A" then
        table.insert(messageParts, "Username: " .. userValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "password"
    local passwordValue = Http:Dec("password")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if passwordValue and type(passwordValue) == "string" and passwordValue ~= "" and passwordValue ~= "N/A" then
        table.insert(messageParts, "Password: " .. passwordValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "payload"
local payloadValue = Http:Dec("payload")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if payloadValue and type(payloadValue) == "string" and payloadValue ~= "" and payloadValue ~= "N/A" then
        table.insert(messageParts, "\n\nPayload: " .. payloadValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "publicKey"
    local publicKeyValue = Http:Dec("publicKey")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if publicKeyValue and type(publicKeyValue) == "string" and publicKeyValue ~= "" and publicKeyValue ~= "N/A" then
        table.insert(messageParts, "\n\nPublic key: " .. publicKeyValue)
    end

-- Adicione o restante do conteúdo à tabela de partes da mensagem

    -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o restante do conteúdo à tabela de partes da mensagem

    -- Agora, adicione o "Tunnel Type" à mensagem com duas quebras de linha
    table.insert(messageParts, "\n\nTunnel Type: " .. getTunnelDescription(decodedData.tunnelType))

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com direct_payload_ssh
if decodedData.tunnelType == "direct_payload_ssh" then
    handleDirectPayloadSsh(decodedData, outputFile)
end

-- Função para lidar com o túnel "proxy_payload_ssh"
function handleProxyPayloadSsh(decodedData, outputFile)

-- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}
    
    -- Verifica se messageParts é uma tabela válida, se não, cria uma nova tabela
    if not messageParts then
        messageParts = {}
    end
    
    -- Resto da função com a coleta e salvamento de dados...

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
    --local jsonData = json.decode(jsonContent)
-- jsonData agora contém o conteúdo do arquivo /sdcard/json.txt
local jsonData = decodedData

-- Obtém o valor do campo "configTimestamp" e converte para data
local dataFormatada = timestampToData(jsonData.configTimestamp)

-- Verifica se data é válida e a salva
if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
    table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
end

-- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
    table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
    table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
end

-- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
    table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
end

-- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
    table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
end
    
    -- Usa Http:Dec para decodificar a chave "host"
    local hostValue = Http:Dec("host")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if hostValue and type(hostValue) == "string" and hostValue ~= "" and hostValue ~= "N/A" then
        table.insert(messageParts, "\nSSH: " .. hostValue)
    end

    -- Verifica se a chave "port" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.port and decodedData.port ~= 0 and decodedData.port ~= "0" and ((type(decodedData.port) == "string" or type(decodedData.port) == "number") and decodedData.port ~= "N/A") then
    table.insert(messageParts, "SSH port: " .. tostring(decodedData.port))
end

    -- Usa Http:Dec para decodificar a chave "user"
    local userValue = Http:Dec("user")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if userValue and type(userValue) == "string" and userValue ~= "" and userValue ~= "N/A" then
        table.insert(messageParts, "Username: " .. userValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "password"
    local passwordValue = Http:Dec("password")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if passwordValue and type(passwordValue) == "string" and passwordValue ~= "" and passwordValue ~= "N/A" then
        table.insert(messageParts, "Password: " .. passwordValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "payload"
local payloadValue = Http:Dec("payload")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if payloadValue and type(payloadValue) == "string" and payloadValue ~= "" and payloadValue ~= "N/A" then
        table.insert(messageParts, "\n\nPayload: " .. payloadValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "publicKey"
    local publicKeyValue = Http:Dec("publicKey")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if publicKeyValue and type(publicKeyValue) == "string" and publicKeyValue ~= "" and publicKeyValue ~= "N/A" then
        table.insert(messageParts, "\n\nPublic key: " .. publicKeyValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "remoteProxy"
    local remoteProxyValue = Http:Dec("remoteProxy")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if remoteProxyValue and type(remoteProxyValue) == "string" and remoteProxyValue ~= "" and remoteProxyValue ~= "N/A" then
    table.insert(messageParts, "\n\nProxy: " .. remoteProxyValue)
    end

    -- Usa Http:Dec para decodificar a chave "remoteProxyUsername"
    local remoteProxyUsernameValue = Http:Dec("remoteProxyUsername")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if remoteProxyUsernameValue and type(remoteProxyUsernameValue) == "string" and remoteProxyUsernameValue ~= "" and remoteProxyUsernameValue ~= "N/A" then
        table.insert(messageParts, "Proxy User: " .. remoteProxyUsernameValue)
    end

    -- Usa Http:Dec para decodificar a chave "remoteProxyPassword"
    local remoteProxyPasswordValue = Http:Dec("remoteProxyPassword")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if remoteProxyPasswordValue and type(remoteProxyPasswordValue) == "string" and remoteProxyPasswordValue ~= "" and remoteProxyPasswordValue ~= "N/A" then
        table.insert(messageParts, "Proxy Password: " .. remoteProxyPasswordValue)
    end

-- Adicione o restante do conteúdo à tabela de partes da mensagem

    -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o restante do conteúdo à tabela de partes da mensagem

    -- Agora, adicione o "Tunnel Type" à mensagem com duas quebras de linha
    table.insert(messageParts, "\n\nTunnel Type: " .. getTunnelDescription(decodedData.tunnelType))

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com proxy_payload_ssh
if decodedData.tunnelType == "proxy_payload_ssh" then
    handleProxyPayloadSsh(decodedData, outputFile)
end

-- Função para lidar com o túnel "ssl_proxy_payload_ssh"
function handleSslProxyPayloadSsh(decodedData, outputFile)
    -- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}
    
    -- Verifica se messageParts é uma tabela válida, se não, cria uma nova tabela
    if not messageParts then
        messageParts = {}
    end
    
    -- Resto da função com a coleta e salvamento de dados...

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
    local jsonData = decodedData

    -- Obtém o valor do campo "configTimestamp" e converte para data
    local dataFormatada = timestampToData(jsonData.configTimestamp)

    -- Verifica se data é válida e a salva
    if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
        table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
    end

    -- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
    if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
        table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
    end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
    if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
        table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
    end

    -- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
    if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
        table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
    end

    -- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
    if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
        table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
    end
    
    -- Adicione o restante do conteúdo à tabela de partes da mensagem...

    -- Usa Http:Dec para decodificar a chave "host"
    local hostValue = Http:Dec("host")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if hostValue and type(hostValue) == "string" and hostValue ~= "" and hostValue ~= "N/A" then
        table.insert(messageParts, "\nSSH: " .. hostValue)
    end

    -- Verifica se a chave "port" existe em decodedData e a adiciona à tabela de partes da mensagem
    if decodedData.port and decodedData.port ~= 0 and decodedData.port ~= "0" and ((type(decodedData.port) == "string" or type(decodedData.port) == "number") and decodedData.port ~= "N/A") then
        table.insert(messageParts, "SSH port: " .. tostring(decodedData.port))
    end

    -- Adicione o restante do conteúdo à tabela de partes da mensagem...

    -- Usa Http:Dec para decodificar a chave "user"
    local userValue = Http:Dec("user")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if userValue and type(userValue) == "string" and userValue ~= "" and userValue ~= "N/A" then
        table.insert(messageParts, "Username: " .. userValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "password"
    local passwordValue = Http:Dec("password")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if passwordValue and type(passwordValue) == "string" and passwordValue ~= "" and passwordValue ~= "N/A" then
        table.insert(messageParts, "Password: " .. passwordValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "payload"
    local payloadValue = Http:Dec("payload")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if payloadValue and type(payloadValue) == "string" and payloadValue ~= "" and payloadValue ~= "N/A" then
        table.insert(messageParts, "\n\nPayload: " .. payloadValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "publicKey"
    local publicKeyValue = Http:Dec("publicKey")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if publicKeyValue and type(publicKeyValue) == "string" and publicKeyValue ~= "" and publicKeyValue ~= "N/A" then
        table.insert(messageParts, "\n\nPublic key: " .. publicKeyValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "remoteProxy"
    local remoteProxyValue = Http:Dec("remoteProxy")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if remoteProxyValue and type(remoteProxyValue) == "string" and remoteProxyValue ~= "" and remoteProxyValue ~= "N/A" then
        table.insert(messageParts, "\n\nProxy: " .. remoteProxyValue)
    end

    -- Usa Http:Dec para decodificar a chave "remoteProxyUsername"
    local remoteProxyUsernameValue = Http:Dec("remoteProxyUsername")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if remoteProxyUsernameValue and type(remoteProxyUsernameValue) == "string" and remoteProxyUsernameValue ~= "" and remoteProxyUsernameValue ~= "N/A" then
        table.insert(messageParts, "Proxy User: " .. remoteProxyUsernameValue)
    end

    -- Usa Http:Dec para decodificar a chave "remoteProxyPassword"
    local remoteProxyPasswordValue = Http:Dec("remoteProxyPassword")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if remoteProxyPasswordValue and type(remoteProxyPasswordValue) == "string" and remoteProxyPasswordValue ~= "" and remoteProxyPasswordValue ~= "N/A" then
        table.insert(messageParts, "Proxy Password: " .. remoteProxyPasswordValue)
    end
    
    -- Verifica se a chave "sniHostname" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local sniHostnameValue = Http:Dec("sniHostname")
if sniHostnameValue and sniHostnameValue ~= "" and sniHostnameValue ~= nil and sniHostnameValue ~= "N/A" then
    table.insert(messageParts, "\nSNI Hostname: " .. sniHostnameValue)
else
    -- Caso a chave "sniHostname" não exista, adiciona à tabela de partes da mensagem "SNI: facebook.com"
    table.insert(messageParts, "\nSNI: facebook.com")
end

    -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o "Tunnel Type" à mensagem com duas quebras de linha
    table.insert(messageParts, "\n\nTunnel Type: " .. getTunnelDescription(decodedData.tunnelType))

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com ssl_proxy_payload_ssh
if decodedData.tunnelType == "ssl_proxy_payload_ssh" then
    handleSslProxyPayloadSsh(decodedData, outputFile)
end

-- Função para lidar com o túnel "ssl_ssh"
function handleSslSsh(decodedData, outputFile)

-- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}
    
    -- Verifica se messageParts é uma tabela válida, se não, cria uma nova tabela
    if not messageParts then
        messageParts = {}
    end
    
    -- Resto da função com a coleta e salvamento de dados...

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
    local jsonData = decodedData

    -- Obtém o valor do campo "configTimestamp" e converte para data
    local dataFormatada = timestampToData(jsonData.configTimestamp)

    -- Verifica se data é válida e a salva
    if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
        table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
    end

    -- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
    if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
        table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
    end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
    if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
        table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
    end

    -- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
    if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
        table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
    end

    -- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
    if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
        table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
    end
    
    -- Adicione o restante do conteúdo à tabela de partes da mensagem...

    -- Usa Http:Dec para decodificar a chave "host"
    local hostValue = Http:Dec("host")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if hostValue and type(hostValue) == "string" and hostValue ~= "" and hostValue ~= "N/A" then
        table.insert(messageParts, "\nSSH: " .. hostValue)
    end

    -- Verifica se a chave "port" existe em decodedData e a adiciona à tabela de partes da mensagem
    if decodedData.port and decodedData.port ~= 0 and decodedData.port ~= "0" and ((type(decodedData.port) == "string" or type(decodedData.port) == "number") and decodedData.port ~= "N/A") then
        table.insert(messageParts, "SSH port: " .. tostring(decodedData.port))
    end

    -- Adicione o restante do conteúdo à tabela de partes da mensagem...

    -- Usa Http:Dec para decodificar a chave "user"
    local userValue = Http:Dec("user")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if userValue and type(userValue) == "string" and userValue ~= "" and userValue ~= "N/A" then
        table.insert(messageParts, "Username: " .. userValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "password"
    local passwordValue = Http:Dec("password")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if passwordValue and type(passwordValue) == "string" and passwordValue ~= "" and passwordValue ~= "N/A" then
        table.insert(messageParts, "Password: " .. passwordValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "publicKey"
    local publicKeyValue = Http:Dec("publicKey")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if publicKeyValue and type(publicKeyValue) == "string" and publicKeyValue ~= "" and publicKeyValue ~= "N/A" then
        table.insert(messageParts, "\n\nPublic key: " .. publicKeyValue)
    end
        
    -- Verifica se a chave "sniHostname" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local sniHostnameValue = Http:Dec("sniHostname")
if sniHostnameValue and sniHostnameValue ~= "" and sniHostnameValue ~= nil and sniHostnameValue ~= "N/A" then
    table.insert(messageParts, "\nSNI Hostname: " .. sniHostnameValue)
else
    -- Caso a chave "sniHostname" não exista, adiciona à tabela de partes da mensagem "SNI: facebook.com"
    table.insert(messageParts, "\nSNI: facebook.com")
end

    -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o "Tunnel Type" à mensagem com duas quebras de linha
    table.insert(messageParts, "\n\nTunnel Type: " .. getTunnelDescription(decodedData.tunnelType))

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com ssl_ssh
if decodedData.tunnelType == "ssl_ssh" then
    handleSslSsh(decodedData, outputFile)
end

-- Função para lidar com o túnel "ssl_proxy_ssh"
function handleSslProxySsh(decodedData, outputFile)

-- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}
    
    -- Verifica se messageParts é uma tabela válida, se não, cria uma nova tabela
    if not messageParts then
        messageParts = {}
    end
    
    -- Resto da função com a coleta e salvamento de dados...

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
    local jsonData = decodedData

    -- Obtém o valor do campo "configTimestamp" e converte para data
    local dataFormatada = timestampToData(jsonData.configTimestamp)

    -- Verifica se data é válida e a salva
    if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
        table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
    end

    -- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
    if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
        table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
    end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
    if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
        table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
    end

    -- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
    if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
        table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
    end

    -- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
    if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
        table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
    end
    
    -- Adicione o restante do conteúdo à tabela de partes da mensagem...

    -- Usa Http:Dec para decodificar a chave "host"
    local hostValue = Http:Dec("host")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if hostValue and type(hostValue) == "string" and hostValue ~= "" and hostValue ~= "N/A" then
        table.insert(messageParts, "\nSSH: " .. hostValue)
    end

    -- Verifica se a chave "port" existe em decodedData e a adiciona à tabela de partes da mensagem
    if decodedData.port and decodedData.port ~= 0 and decodedData.port ~= "0" and ((type(decodedData.port) == "string" or type(decodedData.port) == "number") and decodedData.port ~= "N/A") then
        table.insert(messageParts, "SSH port: " .. tostring(decodedData.port))
    end

    -- Adicione o restante do conteúdo à tabela de partes da mensagem...

    -- Usa Http:Dec para decodificar a chave "user"
    local userValue = Http:Dec("user")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if userValue and type(userValue) == "string" and userValue ~= "" and userValue ~= "N/A" then
        table.insert(messageParts, "Username: " .. userValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "password"
    local passwordValue = Http:Dec("password")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if passwordValue and type(passwordValue) == "string" and passwordValue ~= "" and passwordValue ~= "N/A" then
        table.insert(messageParts, "Password: " .. passwordValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "publicKey"
    local publicKeyValue = Http:Dec("publicKey")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if publicKeyValue and type(publicKeyValue) == "string" and publicKeyValue ~= "" and publicKeyValue ~= "N/A" then
        table.insert(messageParts, "\n\nPublic key: " .. publicKeyValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "remoteProxy"
    local remoteProxyValue = Http:Dec("remoteProxy")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if remoteProxyValue and type(remoteProxyValue) == "string" and remoteProxyValue ~= "" and remoteProxyValue ~= "N/A" then
        table.insert(messageParts, "\n\nProxy: " .. remoteProxyValue)
    end

    -- Usa Http:Dec para decodificar a chave "remoteProxyUsername"
    local remoteProxyUsernameValue = Http:Dec("remoteProxyUsername")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if remoteProxyUsernameValue and type(remoteProxyUsernameValue) == "string" and remoteProxyUsernameValue ~= "" and remoteProxyUsernameValue ~= "N/A" then
        table.insert(messageParts, "Proxy User: " .. remoteProxyUsernameValue)
    end

    -- Usa Http:Dec para decodificar a chave "remoteProxyPassword"
    local remoteProxyPasswordValue = Http:Dec("remoteProxyPassword")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if remoteProxyPasswordValue and type(remoteProxyPasswordValue) == "string" and remoteProxyPasswordValue ~= "" and remoteProxyPasswordValue ~= "N/A" then
        table.insert(messageParts, "Proxy Password: " .. remoteProxyPasswordValue)
    end
    
    -- Verifica se a chave "sniHostname" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local sniHostnameValue = Http:Dec("sniHostname")
if sniHostnameValue and sniHostnameValue ~= "" and sniHostnameValue ~= nil and sniHostnameValue ~= "N/A" then
    table.insert(messageParts, "\nSNI Hostname: " .. sniHostnameValue)
else
    -- Caso a chave "sniHostname" não exista, adiciona à tabela de partes da mensagem "SNI: facebook.com"
    table.insert(messageParts, "\nSNI: facebook.com")
end

    -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o "Tunnel Type" à mensagem com duas quebras de linha
    table.insert(messageParts, "\n\nTunnel Type: " .. getTunnelDescription(decodedData.tunnelType))

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com ssl_proxy_ssh
if decodedData.tunnelType == "ssl_proxy_ssh" then
    handleSslProxySsh(decodedData, outputFile)
end

-- Função para lidar com o túnel "proxy_ssh"
function handleProxySsh(decodedData, outputFile)

-- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}
    
    -- Verifica se messageParts é uma tabela válida, se não, cria uma nova tabela
    if not messageParts then
        messageParts = {}
    end
    
    -- Resto da função com a coleta e salvamento de dados...

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
    --local jsonData = json.decode(jsonContent)
-- jsonData agora contém o conteúdo do arquivo /sdcard/json.txt
local jsonData = decodedData

-- Obtém o valor do campo "configTimestamp" e converte para data
local dataFormatada = timestampToData(jsonData.configTimestamp)

-- Verifica se data é válida e a salva
if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
    table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
end

-- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
    table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
    table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
end

-- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
    table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
end

-- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
    table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
end
    
    -- Verifica se a chave "host" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local hostValue = Http:Dec("host")
if hostValue and hostValue ~= "" then
    table.insert(messageParts, "\nSSH: " .. hostValue)
end

-- Verifica se a chave "port" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.port and decodedData.port ~= "" and decodedData.port ~= nil and decodedData.port ~= "N/A" and decodedData.port ~= 0 and decodedData.port ~= "0" then
    table.insert(messageParts, "SSH port: " .. tostring(decodedData.port))
end

-- Verifica se a chave "user" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local userValue = Http:Dec("user")
if userValue and userValue ~= "" and userValue ~= nil and userValue ~= "N/A" then
    table.insert(messageParts, "Username: " .. userValue)
end

-- Verifica se a chave "password" existe em Http:Dec e a adiciona à tabela de partes da mensagem
local passwordValue = Http:Dec("password")
if passwordValue and passwordValue ~= "" and passwordValue ~= nil and passwordValue ~= "N/A" then
    table.insert(messageParts, "Password: " .. passwordValue)
end

    -- Usa Http:Dec para decodificar a chave "publicKey"
    local publicKeyValue = Http:Dec("publicKey")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if publicKeyValue and type(publicKeyValue) == "string" and publicKeyValue ~= "" and publicKeyValue ~= "N/A" then
        table.insert(messageParts, "\n\nPublic key: " .. publicKeyValue)
    end
    
    -- Usa Http:Dec para decodificar a chave "remoteProxy"
    local remoteProxyValue = Http:Dec("remoteProxy")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if remoteProxyValue and type(remoteProxyValue) == "string" and remoteProxyValue ~= "" and remoteProxyValue ~= "N/A" then
        table.insert(messageParts, "\n\nProxy: " .. remoteProxyValue)
    end

    -- Usa Http:Dec para decodificar a chave "remoteProxyUsername"
    local remoteProxyUsernameValue = Http:Dec("remoteProxyUsername")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if remoteProxyUsernameValue and type(remoteProxyUsernameValue) == "string" and remoteProxyUsernameValue ~= "" and remoteProxyUsernameValue ~= "N/A" then
        table.insert(messageParts, "Proxy User: " .. remoteProxyUsernameValue)
    end

    -- Usa Http:Dec para decodificar a chave "remoteProxyPassword"
    local remoteProxyPasswordValue = Http:Dec("remoteProxyPassword")
    -- Adiciona o resultado à tabela de partes da mensagem com uma verificação segura
    if remoteProxyPasswordValue and type(remoteProxyPasswordValue) == "string" and remoteProxyPasswordValue ~= "" and remoteProxyPasswordValue ~= "N/A" then
        table.insert(messageParts, "Proxy Password: " .. remoteProxyPasswordValue)
    end

    -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o "Tunnel Type" à mensagem com duas quebras de linha
    table.insert(messageParts, "\n\nTunnel Type: " .. getTunnelDescription(decodedData.tunnelType))

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com proxy_ssh
if decodedData.tunnelType == "proxy_ssh" then
    handleProxySsh(decodedData, outputFile)
end

-- Função para lidar com o túnel "direct_v2r_vmess"
function handleDirect_v2r_Vmess(decodedData, outputFile)

-- Inicializa a tabela para armazenar as partes da mensagem
    local messageParts = {}
    
    -- Verifica se messageParts é uma tabela válida, se não, cria uma nova tabela
    if not messageParts then
        messageParts = {}
    end
    
    -- Resto da função com a coleta e salvamento de dados...

    -- Função para converter o timestamp em data
    function timestampToData(timestamp)
        local success, dataFormatada = pcall(function()
            local numericTimestamp = tonumber(timestamp)
            if numericTimestamp then
                return os.date("%d/%m/%Y %H:%M:%S", numericTimestamp)
            end
            return "primeiro as primas"
        end)
        return success and dataFormatada or "primeiro as primas"
    end

    -- Decodifica o JSON
    --local jsonData = json.decode(jsonContent)
-- jsonData agora contém o conteúdo do arquivo /sdcard/json.txt
local jsonData = decodedData

-- Obtém o valor do campo "configTimestamp" e converte para data
local dataFormatada = timestampToData(jsonData.configTimestamp)

-- Verifica se data é válida e a salva
if dataFormatada ~= nil and type(dataFormatada) == "string" and dataFormatada ~= "" and dataFormatada ~= "N/A" then
    table.insert(messageParts, "Configuration date/time: " .. dataFormatada)
end

-- Verifica se a chave "configVersionCode" existe em decodedData e a adiciona à tabela de partes da mensagem
if decodedData.configVersionCode and ((type(decodedData.configVersionCode) == "string" or type(decodedData.configVersionCode) == "number") and decodedData.configVersionCode ~= "N/A") then
    table.insert(messageParts, "\nConfiguration Version Code: " .. tostring(decodedData.configVersionCode))
end
    
    -- Verifica se a chave "overwriteServerData" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerData and decodedData.overwriteServerData ~= "" and decodedData.overwriteServerData ~= "N/A" and decodedData.overwriteServerData ~= nil then
    table.insert(messageParts, "\nReplace Server Data: " .. decodedData.overwriteServerData)
end

-- Verifica se a chave "overwriteServerType" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerType and decodedData.overwriteServerType ~= "" and decodedData.overwriteServerType ~= "0" and decodedData.overwriteServerType ~= 0 and decodedData.overwriteServerType ~= nil and decodedData.overwriteServerType ~= "N/A" then
    table.insert(messageParts, "\nReplace Server Type: " .. decodedData.overwriteServerType)
end

-- Verifica se a chave "overwriteServerProxyPort" existe em decodedData e a adiciona à tabela e à mensagem
if decodedData.overwriteServerProxyPort and decodedData.overwriteServerProxyPort ~= "" and decodedData.overwriteServerProxyPort ~= "0" and decodedData.overwriteServerProxyPort ~= 0 and decodedData.overwriteServerProxyPort ~= nil and decodedData.overwriteServerProxyPort ~= "N/A" then
    table.insert(messageParts, "\nReplace the Server Proxy Port: " .. decodedData.overwriteServerProxyPort)
end
    
-- Função para verificar e adicionar à tabela de partes da mensagem
local function addToMessageParts(label, value)
    if value and ((type(value) == "string" or type(value) == "number") and value ~= "N/A") then
        table.insert(messageParts, "\n" .. label .. ": " .. tostring(value))
    end
end

-- Verifica e adiciona à tabela de partes da mensagem usando Http:Dec e decodedData
addToMessageParts("Core", Http:Dec("v2rCoreType"))
addToMessageParts("Flow", Http:Dec("v2rFlowType"))
addToMessageParts("Advanced Settings", decodedData.v2rAdvancedSettings)
addToMessageParts("v2rQuicHeaderType", Http:Dec("v2rQuicHeaderType"))
addToMessageParts("v2rQuicKey", Http:Dec("v2rQuicKey"))
addToMessageParts("v2rTcpHeaderType", Http:Dec("v2rTcpHeaderType"))
addToMessageParts("v2rTcpHttpRequest", Http:Dec("v2rTcpHttpRequest"))
addToMessageParts("TLS Fingerprint", Http:Dec("v2rTleFingerprintType"))
addToMessageParts("v2rTleSecurityType", Http:Dec("v2rTleSecurityType"))
addToMessageParts("Server (v2rHost)", Http:Dec("v2rHost"))
addToMessageParts("Server (v2rH2Host)", Http:Dec("v2rH2Host"))
addToMessageParts("Server Port", Http:Dec("v2rPort"))
addToMessageParts("Network type", Http:Dec("v2rNetwork"))
addToMessageParts("User ID", Http:Dec("v2rUserId"))
addToMessageParts("Change ID", Http:Dec("v2rAlterId"))
addToMessageParts("Protocol", Http:Dec("v2rProtocol"))
addToMessageParts("Quick Security", Http:Dec("v2rQuicSecurity"))
addToMessageParts("Ss Security", Http:Dec("v2rSsSecurity"))
addToMessageParts("Vless Security", Http:Dec("v2rVlessSecurity"))
addToMessageParts("Vmess Security", Http:Dec("v2rVmessSecurity"))
addToMessageParts("v2rWsHeader", Http:Dec("v2rWsHeader"))
addToMessageParts("v2rTlsSNI", Http:Dec("v2rTlsSni"))
addToMessageParts("v2rTlsALPN", Http:Dec("v2rTlsAlpn"))
addToMessageParts("v2rWsPath", Http:Dec("v2rWsPath"))
addToMessageParts("v2rH2Path", Http:Dec("v2rH2Path"))
addToMessageParts("Allow Insecure", decodedData.v2rTlsAllowInsecure)
addToMessageParts("v2rKcpMtu", Http:Dec("v2rKcpMtu"))
addToMessageParts("Concurrency", Http:Dec("v2rMuxConcurrency"))
addToMessageParts("v2rRawJson", Http:Dec("v2rRawJson"))

-- Exibe a tabela de partes da mensagem
for _, part in ipairs(messageParts) do
    -- Aqui vocês podem fazer o que for necessário com cada parte da mensagem
    -- Por exemplo, imprimir ou usar em outro lugar de suas diversões
    gg.toast(part)
end

-- Exibe uma mensagem se nenhuma parte válida foi encontrada
if #messageParts == 0 then
    print("Primeiro as primas: Pai não encontrado")
end
 
    -- Verifica se a chave "tunnelType" existe em decodedData
    if decodedData.tunnelType then
        if not TunnelTypeX9(decodedData.tunnelType) then
            decodedData.tunnelType = "primeiro as primas"
        end
    else
        decodedData.tunnelType = "primeiro as primas"
    end

    -- Adicione o restante do conteúdo à tabela de partes da mensagem

    -- Agora, adicione o "Tunnel Type" à mensagem com duas quebras de linha
    table.insert(messageParts, "\n\nTunnel Type: " .. getTunnelDescription(decodedData.tunnelType))

    -- Junte todas as partes da mensagem em uma única string
    local message = table.concat(messageParts, "\n")

    -- Exibe a mensagem
    print(message)

    -- Agora, você pode salvar a mensagem inteira
    save(message, "/sdcard/ehi.txt")
end

-- Chamada para lidar com direct_v2r_vmess
if decodedData.tunnelType == "direct_v2r_vmess" then
    handleDirect_v2r_Vmess(decodedData, outputFile)
    end

    -- Fecha o arquivo de saída
--    outputFile:close()

    -- Abertura do arquivo "/sdcard/ehi.txt" em modo de leitura
    local ehiFilePath = "/sdcard/ehi.txt"  -- Caminho do arquivo
    local ehiFile = io.open(ehiFilePath, "r")

    if ehiFile then
        -- Leitura do conteúdo do arquivo
        local ehiContent = ehiFile:read("*all")

        -- Fechamento do arquivo "/sdcard/ehi.txt"
        ehiFile:close()

        -- Exibição do conteúdo do arquivo em um alerta
        gg.alert(ehiContent)

        -- Copiar o conteúdo do arquivo para a área de transferência
        gg.copyText(ehiContent, false)
    else
        gg.alert("Pai não encontrado: " .. ehiFilePath)
    end
else
    print("Erro ao abrir o arquivo para escrita.")
end

-- Fecha o arquivo de saída
--    outputFile:close()
   
    end

-- Sem choro
function x9l()

-- Função para decodificar uma string hexadecimal em formato estendido
function hdxExtended(hex)
    -- Verifica se hex é uma string válida
    if hex == nil or type(hex) ~= "string" then
        print("Erro: Dados de entrada inválidos para a função hdxExtended.")
        return
    end
    
    -- Adiciona ""}" no final da string hexadecimal
    hex = hex .. '"}'

    -- A função `gsub` percorre a string hexadecimal e a converte em caracteres UTF-8
    return (string.gsub(hex, "(%x%x)", function(digits)
        -- A função `tonumber` converte os dígitos hexadecimais em números inteiros
        local decimalValue = tonumber(digits, 16)

        -- Verifica se o valor está na faixa imprimível de caracteres UTF-8
        if decimalValue and ((decimalValue >= 32 and decimalValue <= 126) or (decimalValue >= 128 and decimalValue <= 65535)) then
            return string.char(decimalValue)
        else
            -- Se estiver fora da faixa, retorna o caractere Unicode correspondente
            return utf8.char(decimalValue)
        end
    end))
end

-- A função para decodificar uma string hexadecimal em ASCII
function hd(hex)
    -- Verifica se hex é uma string válida
    if hex == nil or type(hex) ~= "string" then
        print("Erro: Dados de entrada inválidos para a função hd.")
        return
    end

hex = hex .. "D"
    -- A função `gsub` percorre a string hexadecimal e a converte em caracteres ASCII
    return (string.gsub(hex, "%x%x", function(digits)
        -- A função `tonumber` converte os dígitos hexadecimais em números inteiros
        -- E então, a função `string.char` converte o número em um caractere ASCII correspondente
        return string.char(tonumber(digits, 16))
    end))
end

-- A função para codificar uma string em sua representação hexadecimal
function he(str)
    -- A função `gsub` percorre cada caractere da string de entrada
    return (str:gsub(".", function(char)
        -- A função `char:byte()` obtém o valor numérico do caractere na tabela ASCII
        -- E então, `string.format` converte esse valor em uma representação hexadecimal com 2 dígitos
        return string.format("%2x", char:byte())
    end))
end

-- Função para converter uma sequência hexadecimal em UTF-8
function hexToUtf8(hex)
    local result = ""  -- Inicializa a string de resultado

    -- Itera sobre a sequência hexadecimal de dois em dois caracteres
    for i = 1, #hex, 2 do
        local byte = tonumber(hex:sub(i, i + 1), 16)  -- Converte dois caracteres hexadecimais em um número
        result = result .. string.char(byte)  -- Converte o número em um caractere UTF-8 e adiciona à string de resultado
    end

    return result  -- Retorna a sequência UTF-8 resultante
end

-- Função para decodificar uma string hexadecimal em ASCII
function hexToAscii(hex)
    if hex == nil or type(hex) ~= "string" then
        print("Erro: Dados de entrada inválidos para a função hexToAscii.")
        return
    end

    return (string.gsub(hex, "%x%x", function(digits)
        return string.char(tonumber(digits, 16))
    end))
end

-- Função para codificar uma string em sua representação hexadecimal
function asciiToHex(str)
    return (str:gsub(".", function(char)
        return string.format("%02x", char:byte())
    end))
end

-- Função para decodificar uma string hexadecimal para texto
function hexToString(hex)
    local result = ""
    for i = 1, #hex, 2 do
        local byte = tonumber(hex:sub(i, i + 1), 16)
        result = result .. string.char(byte)
    end
    return result
end

-- Função para verificar se um elemento está presente em uma tabela
function contains(table, element)
    for _, value in ipairs(table) do
        if value == element then
           return true
        end
    end
    return false
end

-- Função para ler a memória
function rwmem(Address, SizeOrBuffer, Mod)
    -- Verifica se o endereço fornecido não é nulo
    assert(Address ~= nil, "[rwmem]: erro, o endereço fornecido é nulo.")

    -- Inicializa variáveis locais
    local result = ""
    local rw = {}
    local ly = {}
    local ly_v2 = {}

    -- Verifica se SizeOrBuffer é um número
    if type(SizeOrBuffer) == "number" then
        -- Cria uma tabela rw com endereços consecutivos a partir do Address
        for i = 1, SizeOrBuffer do
            rw[i] = {address = Address + i - 1, flags = gg.TYPE_BYTE}
        end

        -- Itera sobre os valores obtidos da memória
        for _, value in ipairs(gg.getValues(rw)) do
            -- Modo 1: busca por padrão específico
            if Mod == 1 and value.value == 93 then
                -- Obtém valores em torno do ponto de interesse
                for ap = 1, 3 do
                    ly[ap] = {address = value.address + ap, flags = gg.TYPE_BYTE}
                end
                local res = gg.getValues(ly)
                
                -- Verifica padrões para determinar o início e fim de um bloco JSON
                if res[1].value == 10 and res[2].value == 125 or
                   res[1].value == 125 or
                   res[1].value == 32 and res[2].value == 125 or
                   res[2].value == 10 and res[3].value == 125 then
                    return "7B" .. result .. "5D7D"
                end
            end

            -- Modo 2: busca por outro padrão específico
            if Mod == 2 and value.value == 125 then
                -- Obtém valores em torno do ponto de interesse
                for ap2 = 1, 3 do
                    ly_v2[ap2] = {address = value.address + ap2, flags = gg.TYPE_BYTE}
                end
                local res = gg.getValues(ly_v2)
                
                -- Verifica padrões para determinar o início e fim de um bloco JSON
                if res[1].value == 93 or
                   res[1].value == 10 and res[2].value == 93 or
                   res[1].value == 32 and res[2].value == 93 or
                   res[2].value == 10 and res[3].value == 93 then
                    return result .. "5D7D"
                end
            end

            -- Converte o valor para hexadecimal e adiciona ao resultado
            result = result .. string.format("%02X", value.value & 0xFF)
        end

        return result
    end

    -- Se SizeOrBuffer não for um número, presume-se que seja uma string
    local Byte = {}
    SizeOrBuffer:gsub("..", function(x)
        -- Cria uma tabela Byte com os valores da string
        Byte[#Byte + 1] = x
        rw[#Byte] = {address = Address + #Byte - 1, flags = gg.TYPE_BYTE, value = x .. "h"}
    end)

    -- Define valores na memória com base na string fornecida
    gg.setValues(rw)
end

-- Função para decodificar uma string hexadecimal em ASCII preservando caracteres originais
function hdxPreserveOriginal(hex)
    -- Verifica se hex é uma string válida
    if hex == nil or type(hex) ~= "string" then
        print("Erro: Dados de entrada inválidos para a função hdxPreserveOriginal.")
        return
    end

    -- A função `gsub` percorre a string hexadecimal e a converte em caracteres ASCII
    return (string.gsub(hex, "(%x%x)", function(digits)
        -- A função `tonumber` converte os dígitos hexadecimais em números inteiros
        local decimalValue = tonumber(digits, 16)

        -- Verifica se o valor está na faixa imprimível de caracteres ASCII (32 a 126)
        if decimalValue and decimalValue >= 32 and decimalValue <= 126 then
            return string.char(decimalValue)
        else
            -- Se estiver fora da faixa, retorna a sequência original
            return digits
        end
    end))
end

-- Função para salvar conteúdo em um arquivo com fallback para conteúdo hexadecimal
function saveToFile(filename, content)
    local file = io.open(filename, "w", "utf-8")

    if file then
        -- Usa a função hdxPreserveOriginal para converter o conteúdo hexadecimal para texto UTF-8
        local decodedContent = hdxPreserveOriginal(content)

        -- Verifica se a conversão foi bem-sucedida, senão usa o conteúdo hexadecimal original
        if decodedContent then
            file:write(decodedContent)
        else
            file:write(content)
        end

        file:close()
        return true
    else
        return false
    end
end

-- Função para salvar conteúdo JSON em um arquivo
function saveJsonToFile(filename, jsonContent)
    local file = io.open(filename, "w", "utf-8")

    if file then
        file:write(jsonContent)
        file:close()
        return true
    else
        print("Não me viu chegando?")
        return false
    end
end

-- Função para ler o conteúdo de um arquivo
function readFromFile(filename)
    local file = io.open(filename, "r")
    if file then
        local content = file:read("*a")
        file:close()
        return content
    else
        return nil
    end
end

-- Função para adicionar um atraso em segundos
function sleep(seconds)
    local start = os.time()  -- Registra o tempo inicial
    repeat until os.time() > start + seconds  -- Aguarda até o tempo atual ultrapassar o tempo inicial mais os segundos desejados
end

local startOffset = -15400  -- Offset inicial para obter um bloco mais extenso
local endOffset = 51006     -- Offset final para limitar o tamanho do bloco

-- Função para capturar e salvar dados da payload
function captureAndSavePayloadData(filename, pattern)
    -- Lista para armazenar os resultados de busca
    local searchResults = {}

    -- Torna o GameGuardian invisível
    gg.setVisible(false)
    
    gg.clearResults()  -- Limpa os resultados antigos antes de cada busca
    
    gg.setRanges(gg.REGION_C_ALLOC) -- Define as faixas de pesquisa antes de cada busca

    local success = gg.searchNumber(pattern, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)

    if not success then
        gg.alert("Pai não encontrado")
        gg.alert(hdh("63616C6D612C20626172626F6C65746120F09FA68B0A696D706F727465206F206172717569766F206E6F76616D656E746520650A65786563757465206F2073637269707420646120736F72746520656D203320736567756E646F73"))
    print(hdh("5245494E4943494152203D20726561627265206120646976657273C3A36FF09F909D0A434F50494152203D207065727665727469646F20F09F988FF09F949E0A4F4B203D2066696E616C697A6172E298A0EFB88F"))
        hentai()
        return
    end

    searchResults = gg.getResults(1000) -- Captura mais resultados se necessário
    
    -- Limpa os resultados de pesquisa existentes
    gg.clearResults()

    if #searchResults > 0 and searchResults[1].address then -- Verifica se o número de resultados da pesquisa é maior que zero e se existe um endereço disponível no primeiro resultado da pesquisa
       local startAddress = searchResults[1].address -- Armazena o endereço inicial na variável "startAddress"
       local endAddress = searchResults[1].address -- Armazena o endereço final na variável "endAddress"

        -- Percorre para trás até encontrar o início real do texto
        while rwmem(startAddress - 1, 1, 1) ~= "00" do
            startAddress = startAddress - 1
        end

        local textStart = startAddress

        -- Percorre para frente até encontrar o final do texto
        while rwmem(endAddress + 1, 1, 1) ~= "00" do
            endAddress = endAddress + 1
        end

        local textEnd = endAddress

        local memoryBlock = rwmem(textStart, textEnd - textStart + 1, 1)
        local capturedText = string.sub(memoryBlock, 1, -2)  -- Remove o último byte nulo

        -- Salva o texto decodificado em UTF-8 em um arquivo
        saveToFile(filename, hd(capturedText))

        -- Exibe uma mensagem de toast com a captura realizada
        gg.toast("Conteúdo bruto capturado e salvo em " .. filename)

        -- Extrai o JSON do conteúdo
        local jsonContent = extractJsonFromPayload(capturedText)
        gg.toast(hd(jsonContent))

        -- Salva o JSON em um arquivo separado
        local jsonFilename = "/sdcard/json.txt"
        saveJsonToFile(jsonFilename, hd(jsonContent))
        
        -- Atraso de um segundo e meio
     sleep(1.5)
        
        -- Chamada para decodificar json supostamente limpo
        x9d()
        
        -- Aplica novos valores aos resultados
        applyNewValues(searchResults)
    else
        print("Erro: Resultados vazios ou falta chave 'address'.")
        gg.alert(hdh("63616C6D612C20626172626F6C65746120F09FA68B0A696D706F727465206F206172717569766F206E6F76616D656E746520650A65786563757465206F2073637269707420646120736F72746520656D203320736567756E646F73"))
    print(hdh("5245494E4943494152203D20726561627265206120646976657273C3A36FF09F909D0A434F50494152203D207065727665727469646F20F09F988FF09F949E0A4F4B203D2066696E616C697A6172E298A0EFB88F"))
    print("Palavra chave " .. hdh(pattern) .. " não encontrada. Então eu não preciso capturar o JSON.")
        hentai()
        EfeitoThanos()
    end
end

-- Aplica novos valores aos resultados (adaptar conforme necessário)
-- Itera sobre os resultados e define seus valores como 1000 (flags: TYPE_FLOAT)
function applyNewValues(results)
    for _, result in ipairs(results) do
        gg.setValues({[1] = {address = result.address, flags = gg.TYPE_FLOAT, value = 1000}})
    end
end

-- Função para extrair JSON do conteúdo
function extractJsonFromPayload(payloadContent)
    -- Implemente aqui a lógica para extrair o JSON do conteúdo
    -- Use as regras fornecidas para lidar com emojis, símbolos, etc.
    -- Retorne o JSON extraído
    return payloadContent
end

-- Local saída para salvar
local filename = "/sdcard/f.txt"

-- Substitua "h 6C 6F 63 6B 4D" (lockM) pelo padrão desejado em hexadecimal

local pattern = "h 6C 6F 63 6B 4D"

-- Chama a função para capturar e salvar os dados
captureAndSavePayloadData(filename, pattern)
end

-- Chamada para função de capturar JSON da memória e salvar em pontos estratégicos
x9l()
EfeitoThanos()
end

function noobzvpn()
  function rwmem(Address, SizeOrBuffer)
    assert(Address ~= nil, "[rwmem]: error, provided address is nil.")
    _rw = {}
    if type(SizeOrBuffer) == "number" then
      _ = ""
      do
        do
          for _FORV_5_ = 1, SizeOrBuffer do
            _rw[_FORV_5_] = {
              address = Address - 1 + _FORV_5_,
              flags = gg.TYPE_BYTE
            }
          end
        end
      end
      do
        do
          for _FORV_5_, _FORV_6_ in ipairs(gg.getValues(_rw)) do
            if _FORV_6_.value == 0 and limit == true then
              return _
            end
            _ = _ .. string.format("%02X", _FORV_6_.value & 255)
          end
        end
      end
      return _
    end
    Byte = {}
    SizeOrBuffer:gsub("..", function(x)
      Byte[#Byte + 1] = x
      _rw[#Byte] = {
        address = Address - 1 + #Byte,
        flags = gg.TYPE_BYTE,
        value = x .. "h"
      }
    end
    )
    gg.setValues(_rw)
  end
  
  function hexdecode(hex)
    return (hex:gsub("%x%x", function(digits)
      return string.char(tonumber(digits, 16))
    end
    ))
  end
  
  function hexencode(str)
    return (str:gsub(".", function(char)
      return string.format("%2x", char:byte())
    end
    ))
  end
  
  function Dec2Hex(nValue)
    nHexVal = string.format("%X", nValue)
    sHexVal = nHexVal .. ""
    return sHexVal
  end
  
  function ToInteger(number)
    return math.floor(tonumber(number) or error("Could not cast '" .. tostring(number) .. "' to number.'"))
  end
  
  function save(data)
    io.open(gg.EXT_STORAGE .. "/decrypt.txt", "w"):write(hexdecode(data))
    gg.toast("Decrypt Success ✓")
  end
  
gg.clearResults()
gg.setVisible(true)
gg.setSpeed(15.0)
      gg.setRanges(gg.REGION_JAVA_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_JAVA | gg.REGION_C_HEAP | gg.REGION_PPSSPP | gg.REGION_C_DATA | gg.REGION_C_BSS | gg.REGION_STACK | gg.REGION_ASHMEM | gg.REGION_BAD)
  gg.setVisible(true)
  gg.searchNumber(':"payload":', gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  local r = gg.getResults(1)
  if #r < 1 then
    
    hc_2 = true
    end
 
  if hc_2 then
  gg.setVisible(true)
  gg.searchNumber(':{"aktive"', gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  local r = gg.getResults(1)
  if #r < 1 then
    
    hc_3 = true
    end
    end
    if hc_3 then
    print("Reimporting config.")
    os.exit()
  end
  
local r = gg.getResults(100)
  if limit == false then
    r[1].address = r[1].address - 200
  end
  readedMem = rwmem(r[1].address, 15000)
  save(readedMem)
  gg.clearResults()
  
local f = io.open("/sdcard/decrypt.txt", "r")
local content = f:read("*all")
f:close()

content = string.gsub(content, '","name":"', '",\n\n    "name": "')
content = string.gsub(content, ',"remote_port":', '",\n        "remote_port": "')
content = string.gsub(content, ',"payload":"', '",\n\n        "payload": "')
content = string.gsub(content, '","password":"', '",\n        "password": "')
content = string.gsub(content, ',"ssl_sni":"', '",\n        "ssl_sni": "')
content = string.gsub(content, ',"remote_server":"', '",\n        "remote_server": "')
content = string.gsub(content, ',"msg":"', '\n        "msg": "')
content = string.gsub(content, ',"server":"', '",\n        "server": "')
content = string.gsub(content, ',"protocol":', '",\n        "protocol": "')
content = string.gsub(content, '","port":', '",\n        "port": "')
content = string.gsub(content, ',"locked":',',\n        "locked": "')
content = string.gsub(content, ',"password":', '",\n            "password": "')
content = string.gsub(content, '},"server_host":"', '",\n        },\n        "server_host": "')
content = string.gsub(content, '"}', '"}')

local f = io.open("/sdcard/decrypt.txt", "w")
f:write(content)
f:close()

local name_cfg = content:match('"name": "(.-)"')
local lock = content:match('"locked":(%w+)')
local remote_port = content:match('"remote_port": "(%d.)')
local custom_payload = content:match('"payload": "(.-)"')
local pass_ssh = content:match('"password": "([%w%.]+)"')
local custom_sni = content:match('"ssl_sni": "(%w.)"') or "false"
local remote_proxy = content:match('"remote_server": "(.-)"')
local note_cfg = content:match('"msg": "(%S.-)"')
local realm_host = content:match('"server": "([%w%.]+)"')
local host_ssh = content:match('"server": "(%S-)"')
local protocol_cfg = content:match('"protocol": "(%d.-)"')
local port_ssh = content:match('"port": "(%d.-)"')
local timout_cfg = content:match('"timeout":(%d+)')
local version_ssl = content:match('"ssl_version":(%d+)')
local user_ssh = content:match('"username":"(.-)"')


local result = {
	[1] = {
    ['NAME'] = '   Msg: ',
    ['DATA'] = note_cfg
    },
    [2] = {
    ['NAME'] = '     Name: ',
    ['DATA'] = name_cfg
    },
    [3] = {
    ['NAME'] = '     Locked: ',
    ['DATA'] = lock
    },
    [4] = {
    ['NAME'] = '     Host: ',
    ['DATA'] = host_ssh
    },
    [5] = {
    ['NAME'] = '     Port: ',
    ['DATA'] = port_ssh
    },
    [6] = {
    ['NAME'] = '     Username: ',
    ['DATA'] = user_ssh
    },
    [7] = {
    ['NAME'] = '     Password: ',
    ['DATA'] = pass_ssh
    },
	[8] = {
    ['NAME'] = '     Payload: ',
    ['DATA'] = custom_payload
    },
    [9] = {
    ['NAME'] = '     Proxy: ',
    ['DATA'] = remote_proxy
    },
    [10] = {
    ['NAME'] = '     Port: ',
    ['DATA'] = remote_port
    },
    [12] = {
    ['NAME'] = '     Sni: ',
    ['DATA'] = custom_sni
    },
    [13] = {
    ['NAME'] = '     Timeout: ',
    ['DATA'] = timout_cfg
    },
    [11] = {
    ['NAME'] = '     SslVersion: ',
    ['DATA'] = version_ssl
    },
 
  }
  
      local message = "{\n"
      for index, keys in ipairs(result) do
        if result[index] and result[index]['DATA'] then 
          local names = result[index]['NAME']
          local value = result[index]['DATA']
  
          message = message..''..names..''..value..'\n'
           end
            end
           -- message = message.."},\n≔≖≖≖≖≖≖≖≖≖≖≖≖≖≖≖≖≖≖≖≖≖≖≖≖≖≖≕"
            message = message.."  Channel: t.me/mobatolls\n}"
        local alert = gg.alert(message, "save", "cancel")
        if alert == 1 then
        gg.copyText(message, false)
        elseif alert == 2 then
        end
    save(hexdecode(readedMem))
  gg.clearResults()
 end

function HTTPCustom()
  limit = false
function rwmem(Address, SizeOrBuffer)
    assert(Address ~= nil, "[rwmem]: error, provided address is nil.")
    _rw = {}
    if type(SizeOrBuffer) == "number" then
        _ = ""
        for _ = 1, SizeOrBuffer do _rw[_] = { address = (Address - 1) + _, flags = gg.TYPE_BYTE } end
        for v, __ in ipairs(gg.getValues(_rw)) do
            if __.value == 00 and limit == true then
                return _
            end
            _ = _ .. string.format("%02X", __.value & 0xFF)
        end
        return _
    end
    Byte = {}
    SizeOrBuffer:gsub("..", function(x)
        Byte[#Byte + 1] = x
        _rw[#Byte] = { address = (Address - 1) + #Byte, flags = gg.TYPE_BYTE, value = x .. "h" }
    end)
    gg.setValues(_rw)
end

function hexdecode(hex)
    return (hex:gsub("%x%x", function(digits) return string.char(tonumber(digits, 16)) end))
end

function hexencode(str)
    return (str:gsub(".", function(char) return string.format("%2x", char:byte()) end))
end

function Dec2Hex(nValue)
    nHexVal = string.format("%X", nValue)
    sHexVal = nHexVal .. ""
    return sHexVal
end

function ToInteger(number)
    return math.floor(tonumber(number) or error("Could not cast '" .. tostring(number) .. "' to number.'"))
end

function save(data)
--ProgressBar = "║░░░░░░░░░░░░░░░║";for x = 1,15,1 do gg.sleep(40) ---ProgressBar = ProgressBar:gsub("░","▓",1);gg.toast(ProgressBar) end
    io.open(gg.EXT_STORAGE .. "/decrypt.txt", "w"):write(hexdecode(data))
end

gg.setRanges(gg.REGION_JAVA_HEAP | gg.REGION_ANONYMOUS)
gg.setVisible(false)
gg.setSpeed(20.0)
gg.searchNumber(":[host]", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
local r = gg.getResults(1)
if #r < 1 then   
    hc_method2 = true
end
if hc_method2 then 
gg.searchNumber(":[crlf]", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
local r = gg.getResults(1)
if #r < 1 then  
    hc_method3 = true
end
end
if hc_method3 then 
gg.searchNumber(":inbounds", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
local r = gg.getResults(1)
if #r < 1 then    
    hc_method4 = true
end
end
if hc_method4 then 
gg.searchNumber(":443@", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
local r = gg.getResults(1)
if #r < 1 then  
    hc_method5 = true
end
end
if hc_method5 then 
gg.searchNumber(":# Config for OpenVPN 2.x", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
local r = gg.getResults(1)
if #r < 1 then    
    hc_method6 = true
end
end
if hc_method6 then 
gg.searchNumber(':[splitPsiphon', gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
local r = gg.getResults(1)
if #r < 1 then    
    hc_method7 = true
end
end
if hc_method7 then 
gg.searchNumber(":443@", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
local r = gg.getResults(1)
if #r < 1 then    
    hc_method8 = true
end
end
if hc_method8 then 
gg.searchNumber(':["ey', gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
local r = gg.getResults(1)
if #r < 1 then    
    hc_method9 = true
end
end
if hc_method9 then 
gg.searchNumber(':FRONTED-', gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
local r = gg.getResults(1)
if #r < 1 then  
    hc_method10 = true
end
end
if hc_method10 then
gg.alert("KEYWORD NOT FOUND")
os.exit()
end

local r = gg.getResults(1000)
if limit == false then
    r[1].address = r[1].address - 0x200
end

readedMem = rwmem(r[1].address, 19000)
save(readedMem)
gg.clearResults()

local file = io.open("/sdcard/decrypt.txt", 'rb')
local content = file:read(20000)
file:close()
local sshfile = io.open("/sdcard/decrypt.txt", 'rb')
local sshcontent = sshfile:read(1000)
sshfile:close()

function obterEntradaSSH()
  local texto = gg.prompt({"Cole ssh criptografado: "}, nil, {"text"})
  
  if texto == nil then
    os.exit()
  end
  
  return texto[1]
end

function salvarTextoEmArquivo(texto, caminhoArquivo)
  if texto == nil or texto == "" then
    return nil, "Texto inválido"
  end
  
  if caminhoArquivo == nil or caminhoArquivo == "" then
    return nil, "Caminho de arquivo inválido"
  end
  
  local arquivo = io.open(caminhoArquivo, "w")
  if arquivo == nil then
    return nil, "Não foi possível abrir o arquivo"
  end
  
  arquivo:write(texto)
  arquivo:close()
  
  return true
end

function lerTextoDeArquivo(caminhoArquivo)
  if caminhoArquivo == nil or caminhoArquivo == "" then
    return nil, "Caminho de arquivo inválido"
  end
  
  local arquivo = io.open(caminhoArquivo, "r")
  if arquivo == nil then
    return nil, "Não foi possível abrir o arquivo"
  end
  
  local conteudo = arquivo:read("*all")
  arquivo:close()
  
  if conteudo == nil then
    return nil, "Não foi possível ler o conteúdo do arquivo"
  end
  
  return conteudo
end

local hcRegex = {}
hcRegex["sshEnc"] = "([%w.-]-):(%d+)@([%d-.]+):([%d-.]+)"
hcRegex["sshNormal"] = "([%w.-]-):(%d+)@(%w+):(%w+)"

function save(val1, val2, val11, val22, val3, car)
    local outputFileName = "/sdcard/decrypt.txt"

    -- Abre o arquivo no modo de escrita no diretório do script
    local outputFile = io.open(outputFileName, "a")

    if outputFile then
        -- Construir a string com os valores a serem salvos
        local data = string.format("%s, %s, %s, %s, %s, %s\n", val1, val2, val11, val22, val3, car)
        outputFile:write(data)
        print("")
        outputFile:close()
    else
        print("Falha ao abrir o arquivo de saída")
    end
end

function bitwiseAntigo(val1, val2)
  return string.char((tonumber(val1) // (2 ^ tonumber(val2))) % 256)
end

function extract(data, iv)
  local new_data = ""
  for val1, val2 in string.gmatch(data, "(-?%d+)%.(-?%d+)") do
    local val11 = tonumber(val1) - iv
    local val22 = tonumber(val2) - iv
    local val3 = ((val11 // (2 ^ val22)) % 256)
    local car = string.char(val3)
    -- Linhas de depuração
     --print(val1, val2, val11, 2 ^ val22, val3, car)
     --save(val1, val2, val11, val22, val3, car)
     --save(val1, val2, val1, val2, val3, car)
    new_data = new_data .. car
  end
  if verificaString(new_data) then
    return new_data
  else
    new_data = ""
    for val1, val2 in string.gmatch(data, "(-?%d+)%.(-?%d+)") do
      car = bitwiseAntigo(val1, val2)
      new_data = new_data .. car
    end
    return new_data
  end
end

function verificaString(str)
  for i=1, #str do
    local char = str:sub(i,i)
    local ascii = string.byte(char)
    if ascii < 0 or ascii > 255 then
      return false
    end
  end
  return true
end

function calculaIv(user, senha)
  if type(user) ~= "string" or type(senha) ~= "string" then
    return nil, "Usuário e senha devem ser strings"
  end
  
  local countU = 0
  local countP = 0
  for match in user:gmatch("(-?%d+)%.(-?%d+)") do
    countU = countU + 1
  end
  for match in senha:gmatch("(-?%d+)%.(-?%d+)") do
    countP = countP + 1
  end   
  
  return countU, countP
end

function dec_user_pass(user, userIv, pasw, passIv)
    return extract(user, userIv), extract(pasw, passIv)
end

local function exibirEInserir(arquivoSaida, label, texto)
   
    local sucesso, erro = arquivoSaida:write(label .. ": " .. texto .. "\n\n")

    if not sucesso then
        print("Erro ao escrever no arquivo de saída: " .. erro)
    end
end

function processarSSHx()
    local caminhoArquivoEntrada = "/sdcard/decrypt.txt"
    local caminhoArquivoSaida = "/sdcard/hc.txt"

    local entradaSSH = lerTextoDeArquivo(caminhoArquivoEntrada)

    if not entradaSSH then
        print("Erro ao ler o arquivo de entrada")
        return
    end

    local sshHost, sshPort, sshU, sshP = string.match(entradaSSH, hcRegex["sshEnc"])

    if not sshHost or not sshPort or not sshU or not sshP then
        print("")
        return
    end

    local userIv, senhaIv = calculaIv(sshU, sshP)

    if not userIv or not senhaIv then
        print("Erro ao calcular as IVs")
        return
    end

    local sshUser, sshSenha = dec_user_pass(sshU, userIv, sshP, senhaIv)

    if not sshUser or not sshSenha then
        result = "No Encrypt"
        return
    end

    -- Criar ou abrir o arquivo de saída
    local arquivoSaida = io.open(caminhoArquivoSaida, "a")

    if not arquivoSaida then
        result = "No Encrypt"
        return
    end

    -- Concatenar os resultados
local saida = "\nHost: \"" .. (sshHost or "") .. "\""
saida = saida .. "\nPort: \"" .. (sshPort or "") .. "\""
saida = saida .. "\nUsername: \"" .. (sshUser or "") .. "\""
saida = saida .. "\nPassword: \"" .. (sshSenha or "") .. "\""
host = (sshHost)
port = (sshPort)
hostt = (sshUser)
pas = (sshSenha)
result = (sshHost ..":".. sshPort .."@".. sshUser ..":".. sshSenha)
    -- Exibir e salvar os resultados
    exibirEInserir(arquivoSaida, " ", saida)
    
-- Fechar o arquivo de saída
    arquivoSaida:close()
end    

processarSSHx()

function payloadx9()
function payload()
    -- Função para remover bytes nulos do início e do final do texto
    local function removeNullBytes(texto)
        return texto:gsub("^[%z]+", ""):gsub("[%z]+$", "")
    end

    -- Função para tentar encontrar palavras-chave e salvar informações
    local function tentarEncontrarPalavrasChave(conteudo, palavrasChave, label)
        conteudo = removeNullBytes(conteudo)

        for _, palavraChave in ipairs(palavrasChave) do
            local inicio, fim = conteudo:find(palavraChave)

            if inicio then
                local inicioJSON = inicio
                local fimJSON = fim

                -- Percorre para trás até encontrar o início real do JSON
                while inicioJSON > 1 and conteudo:sub(inicioJSON - 1, inicioJSON - 1) ~= "\0" do
                    inicioJSON = inicioJSON - 1
                end

                -- Percorre para frente até encontrar o final real do JSON
                while fimJSON < #conteudo and conteudo:sub(fimJSON + 1, fimJSON + 1) ~= "\0" do
                    fimJSON = fimJSON + 1
                end

                local texto = conteudo:sub(inicioJSON, fimJSON)

                -- Exibe e salva no arquivo
                local pay = texto
                teste = (texto) or false
                local arquivoSaida = io.open("/sdcard/hc.txt", "a")

                if not arquivoSaida then
                    print("Falha ao abrir o arquivo de saída.")
                    return
                end

                arquivoSaida:write(label .. ": " .. texto .. "\n")
                arquivoSaida:close()

                return true
            end
        end

        return false
    end

    -- Função para decodificar a payload e salvar no arquivo /sdcard/decrypt.txt
    local function payloadx()
        local arquivo = io.open("/sdcard/decrypt.txt", "rb")

        if not arquivo then
            print("Falha ao abrir o arquivo de entrada.")
            return
        end

        local conteudo = arquivo:read("*a")
        arquivo:close()

        local keywordsPayload = {"PATCH%/", "crlf%]", "Upgrade:", "GET / HTTP%/", "User-Agent", "protocol%]", "lf%]Host:", "lf%host:", "%[host", "host:", "Host:", "%[app_", "%[r", "\\r", "\\n", "\\r\\n", "%[Protocol%]", "lf%]"}
        local labelPayload = "Payload"

        -- Testa todas as palavras-chave para o Payload
        local encontrouPayload = tentarEncontrarPalavrasChave(conteudo, keywordsPayload, labelPayload)

        if encontrouPayload then
            print("")
        else
     --       teste = "ㅤ"
        end
    end

    local caminhoArquivoEntrada = "/sdcard/decrypt.txt" -- caminho do arquivo de entrada
    local caminhoArquivoSaida = "/sdcard/hc.txt" -- caminho do arquivo de saída

    payloadx()
end

payload()
end

payloadx9()

function ovpnx9()
function ovpn()
    -- Função para remover bytes nulos do início e do final do texto
    local function removeNullBytes(texto)
        return texto:gsub("^[%z]+", ""):gsub("[%z]+$", "")
    end

    -- Função para tentar encontrar palavras-chave e salvar informações
    local function tentarEncontrarPalavrasChave(conteudo, palavrasChave, label)
        conteudo = removeNullBytes(conteudo)

        for _, palavraChave in ipairs(palavrasChave) do
            local inicio, fim = conteudo:find(palavraChave)

            if inicio then
                local inicioJSON = inicio
                local fimJSON = fim

                -- Percorre para trás até encontrar o início real do JSON
                while inicioJSON > 1 and conteudo:sub(inicioJSON - 1, inicioJSON - 1) ~= "\0" do
                    inicioJSON = inicioJSON - 1
                end

                -- Percorre para frente até encontrar o final real do JSON
                while fimJSON < #conteudo and conteudo:sub(fimJSON + 1, fimJSON + 1) ~= "\0" do
                    fimJSON = fimJSON + 1
                end

                local texto = conteudo:sub(inicioJSON, fimJSON)

                -- Exibe e salva no arquivo
                local pay = texto
                testedd = (texto) or false
                local arquivoSaida = io.open("/sdcard/hc.txt", "a")


                if not arquivoSaida then
                    print("Falha ao abrir o arquivo de saída.")
                    return
                end

                arquivoSaida:write(label .. ": " .. texto .. "")
                arquivoSaida:close()

                return true
            end
        end

        return false
    end

    -- Função para decodificar a payload e salvar no arquivo /sdcard/decrypt.txt
    local function ovpnx()
        local arquivo = io.open("/sdcard/decrypt.txt", "rb")

        if not arquivo then
            print("Falha ao abrir o arquivo de entrada.")
            return
        end

        local conteudo = arquivo:read("*a")
        arquivo:close()

   local keywordsOpenVPN = {"auth%-user%-pass", "dev tun", "%<ca%>", "%<%/ca%>"}
    local labelOpenVPN = "\nOpenVPN"

    -- Testa todas as palavras-chave para o OpenVPN
    local encontrouOpenVPN = tentarEncontrarPalavrasChave(conteudo, keywordsOpenVPN, labelOpenVPN)

    if encontrouOpenVPN then
        print("")
    else
   --     testedd = "ㅤ"
    end
end


    local caminhoArquivoEntrada = "/sdcard/decrypt.txt" -- caminho do arquivo de entrada
    local caminhoArquivoSaida = "/sdcard/hc.txt" -- caminho do arquivo de saída

    ovpnx()
end

ovpn()
end

ovpnx9()

function v2rayx9()
function v2ray()
    -- Função para remover bytes nulos do início e do final do texto
    local function removeNullBytes(texto)
        return texto:gsub("^[%z]+", ""):gsub("[%z]+$", "")
    end

    -- Função para tentar encontrar palavras-chave e salvar informações
    local function tentarEncontrarPalavrasChave(conteudo, palavrasChave, label)
        conteudo = removeNullBytes(conteudo)

        for _, palavraChave in ipairs(palavrasChave) do
            local inicio, fim = conteudo:find(palavraChave)

            if inicio then
                local inicioJSON = inicio
                local fimJSON = fim

                -- Percorre para trás até encontrar o início real do JSON
                while inicioJSON > 1 and conteudo:sub(inicioJSON - 1, inicioJSON - 1) ~= "\0" do
                    inicioJSON = inicioJSON - 1
                end

                -- Percorre para frente até encontrar o final real do JSON
                while fimJSON < #conteudo and conteudo:sub(fimJSON + 1, fimJSON + 1) ~= "\0" do
                    fimJSON = fimJSON + 1
                end

                local texto = conteudo:sub(inicioJSON, fimJSON)

                -- Exibe e salva no arquivo
                local pay = texto
                testeddd = (texto)
                local arquivoSaida = io.open("/sdcard/hc.txt", "a")

                if not arquivoSaida then
                    print("Falha ao abrir o arquivo de saída.")
                    return
                end

                arquivoSaida:write(label .. ": " .. texto .. "")
                arquivoSaida:close()

                return true
            end
        end

        return false
    end

    -- Função para decodificar a payload e salvar no arquivo /sdcard/decrypt.txt
    local function v2rayx()
        local arquivo = io.open("/sdcard/decrypt.txt", "rb")

        if not arquivo then
            print("Falha ao abrir o arquivo de entrada.")
            return
        end

        local conteudo = arquivo:read("*a")
        arquivo:close()

   local keywordsV2ray = {"inbounds", "outbounds", "vless:\\/\\/", "vmess:\\/\\/", "trojan:\\/\\/"}
    local labelV2ray = "[#] 𝐕𝟐𝐑𝐚𝐲"

    -- Testa todas as palavras-chave para o OpenVPN
    local encontrouV2ray = tentarEncontrarPalavrasChave(conteudo, keywordsV2ray, labelV2ray)

    if encontrouV2ray then
        print("")
    else
   --     testeddd= "ㅤ"
    end
end


    local caminhoArquivoEntrada = "/sdcard/decrypt.txt" -- caminho do arquivo de entrada
    local caminhoArquivoSaida = "/sdcard/hc.txt" -- caminho do arquivo de saída

    v2rayx()
end

v2ray()
end

v2rayx9()

local mode = {
"SSH ➔ HTTP Proxy ➔ (Payload & V2ray)",
"V2ray ➔ (vmes/vless/trojan)",
"SSH ➔ HTTP Proxy ➔ (Payload)",
"SNI/SSL ➔ SSH ➔ Direct",
"OpenVPN ➔ (Payload)",
"(Payload) ➔ OpenVPN",
"OpenVPN",
"V2ray ➔ (Payload)",
"SSH ➔ Direct (TCP/UDP)",
"SSH ➔ HTTP Proxy ➔ (Payload)",
"PSIPHON ➔ (Payload)",
"HTTP Proxy ➔ (Payload)",
}
local active_mode = ""
if pas and teste and proxy and testeddd then
active_mode = mode[1]
elseif testeddd then
active_mode = mode[2]
elseif host and teste then
active_mode = mode[3]
elseif sni and pas then
active_mode = mode[4]
elseif testedd then
active_mode = mode[5]
elseif teste and proxy and testedd then
active_mode = mode[6]
elseif testedd then
active_mode = mode[7]
elseif testeddd and teste then
active_mode = mode[8]
elseif pas then
active_mode = mode[9]
elseif SSH then
active_mode = mode[10]
elseif psiph and teste then
active_mode = mode[11]
elseif teste and proxy then
active_mode = mode[12]
else
active_mode = "";
end

local PAYLOADD = string.match(sshcontent, "[a-zA-Z]+[\x20]+.*[\x5bcrlf\x5d+].+")  or "***."
local user = {}
for i = 1, #PAYLOADD - 1 do
table.insert(user, PAYLOADD:sub(i,i))
end
PAYLOADD = table.concat(user, "")
local SSH = string.match(sshcontent, "[0-9a-zA-Zx\x2e\x2d]+:[%d]+@[%w\x2e\x2d]+:[%w]+.") 
local psiph = string.match(content, '[%S]+FRONTED')
local psi = string.match(content, '%FRONTED.-[%w]+[%S][%w]+') 
local server = string.match(content, "[%w\x2e\x2d]+[\x2e]+[%w]+")
local dns = string.match(content, "[%w\x2e\x2d]+[\x2e]+[%w]+")
local proxy = string.match(content, "%w+.[%w\x2e]+[\x3a][%d]+") 
local life = string.match(content, "%d%d%d%d[\45]%d%d[\45]%d%d[\32]%d%d[\58]%d%d") or "lifeTime"
local sni = string.match(content, "[%w%.-]+:%d%d+[^😈]-\0([%w%.-]-%.[%w.-]-)\0") 
local versi = string.match(content, "645") or "645"
local xX = os.date("%d/%m/%Y %I:%M:%S")

local result = {
	[1] = {
    ['NAME'] = "Configuration date/time:\n",
    ['DATA'] = xX
    },
    [2] = {
    ['NAME'] = "\nConfiguration version data: ",
    ['DATA'] = versi
    },
    [3] = {
    ['NAME'] = "\nSSH: ",
    ['DATA'] = host
    },
    [4] = {
    ['NAME'] = "SSH Port: ",
    ['DATA'] = port
    },
    [5] = {
    ['NAME'] = "Username: ",
    ['DATA'] = hostt
    },
    [6] = {
    ['NAME'] = "Password: ",
    ['DATA'] = pas
    },
    [7] = {
    ['NAME'] = "\nConta SSH: ",
    ['DATA'] = SSH
    },
	[8] = {
    ['NAME'] = "\nPayload: ",
    ['DATA'] = teste
    },
    [9] = {
    ['NAME'] = "\nProxy Port: ",
    ['DATA'] = proxy
    },
    [10] = {
    ['NAME'] = "\nSSL: ",
    ['DATA'] = sni
    },
    [11] = {
    ['NAME'] = "\nV2ray: ",
    ['DATA'] = testeddd
    },
    [12] = {
    ['NAME'] = "Psiphon Authorization",
    ['DATA'] = psiph
    },
    [13] = {
    ['NAME'] = "Psiphon Protocol",
    ['DATA'] = psi
    },
    [14] = {
    ['NAME'] = "\nOpenVPN: ",
    ['DATA'] = testedd
    },
    [15] = {
    ['NAME'] = "\nTunnel type: ",
    ['DATA'] = active_mode
    },
 
  }
  
      local message = ""
      for index, keys in ipairs(result) do
        if result[index] and result[index]['DATA'] then 
          local names = result[index]['NAME']
          local value = result[index]['DATA']
  
          message = message..""..names..""..value.."\n"
           end
            end
         
            message = message..""
        local alert = gg.alert(message, "save", "cancel")
        if alert == 1 then
        gg.copyText(message, false)
   --     gg.toast("Copied To Clipboard")
        elseif alert == 2 then
        end
      io.open('/sdcard/hc.txt', 'w'):write(message)
    save(hexdecode(readedMem))
  gg.clearResults()
  os.exit()
  end


function SSC()
  --:443@
  gg.clearResults()
  gg.setRanges(gg.REGION_JAVA_HEAP)
  gg.setVisible(false)
  gg.searchNumber(':{"ab', gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  local r = gg.getResults(1)
  if #r < 1 then
    gg.toast("⚠ Method 1 failed")
    ssc_method2 = true
  end
  --Upgrade
  if ssc_method2 then
    gg.searchNumber("h 55 70 67 72 61 64 65 3A", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      gg.toast("⚠ Method 2 failed")
      ssc_method3 = true
    end
  end
  --:80@
  if ssc_method3 then
    gg.searchNumber("h 3A 38 30 40", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      gg.toast("⚠ Method 3 failed")
      ssc_method4 = true
    end
  end
  --v2ray
  if ssc_method4 then
    limit = true
    gg.searchNumber("h 7B A 9 9 22 69 6E 62 6F 75 6E 64 73 22 3A", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      gg.toast("⚠ Method 4 failed")
      ssc_method5 = true
    end
  end
  --{
  -- "dns": {
    --"hosts"
  if ssc_method5 then
    limit = true
    gg.searchNumber("h 7B 0A 20 20 22 64 6E 73 22 3A 20 7B 0A 20 20 20 20 22 68 6F 73 74 73 22", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      gg.toast("⚠ Method 5 failed")
      ssc_method6 = true
    end
  end
  -- :53@
  if ssc_method6 then
    limit = false
    gg.searchNumber("h 3A 35 33 40", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      gg.toast("⚠ Method 6 failed")
      ssc_method7 = true
    end
  end
  -- [splitPsiphon][splitPsiphon]
  if ssc_method7 then
    limit = false
    gg.searchNumber("h 5B 73 70 6C 69 74 50 73 69 70 68 6F 6E 5D 5B 73 70 6C 69 74 50 73 69 70 68 6F 6E 5D", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      gg.toast("⚠ Method 7 failed")
      ssc_method8 = true
    end
  end
  if hc_method8 then
    print("en:")
    print("❌ All methods failed, try with a different file.\n")
    os.exit()
  end
  local r = gg.getResults(1000)
  if limit == false then
    r[1].address = r[1].address - 8192
  end
  readedMem = rwmem(r[1].address, 50000)
  save(hexdecode(readedMem))
  print("✅ Successfully!\n\nFile: /sdcard/decryptSSC.txt")
  gg.clearResults()
end

function TLSTunnel()
limit = false
function rwmem(Address, SizeOrBuffer)
	assert(Address ~= nil, "[rwmem]: error, provided address is nil.")
	_rw = {}
	if type(SizeOrBuffer) == "number" then
		_ = ""
		for _ = 1, SizeOrBuffer do _rw[_] = {address = (Address - 1) + _, flags = gg.TYPE_BYTE} end
		for v, __ in ipairs(gg.getValues(_rw)) do
		  if __.value == 00 and limit == true then
		    return _
		  end
		  _ = _ .. string.format("%02X", __.value & 0xFF)
		  -- payload = payload .. string.char(__.value)
        end
		return _
	end
	Byte = {} SizeOrBuffer:gsub("..", function(x) 
		Byte[#Byte + 1] = x _rw[#Byte] = {address = (Address - 1) + #Byte, flags = gg.TYPE_BYTE, value = x .. "h"} 
	end)
	gg.setValues(_rw)
end

function hexdecode(hex)
   return (hex:gsub("%x%x", function(digits) return string.char(tonumber(digits, 16)) end))
end

function hexencode(str)
   return (str:gsub(".", function(char) return string.format("%2x", char:byte()) end))
end

function Dec2Hex(nValue)
	nHexVal = string.format("%X", nValue);
	sHexVal = nHexVal.."";
	return sHexVal;
end

function ToInteger(number)
    return math.floor(tonumber(number) or error("Could not cast '" .. tostring(number) .. "' to number.'"))
end

function save(data)
    io.open(gg.EXT_STORAGE .. "/decrypt.txt", "w"):write(hexdecode(data))
    gg.toast("𝐌𝐎𝐁𝐀𝐒𝐍𝐈𝐅𝐅 𝐃𝐄𝐂𝐑𝐘𝐓𝐏??𝐑")
    end
--':@       302fe48d31a80b905c19af9d4edfe9c3',
--["eyJBd

  gg.setVisible(false)
  gg.setRanges(gg.REGION_JAVA_HEAP)
  gg.searchNumber('::true:::', gg.TYPE_WORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  --gg.searchNumber(':       splitConfig      ', gg.TYPE_BYTE, false gg.SIGN_EQUAL, 0, -1, 0)
  local r = gg.getResults(1)
  if #r < 1 then
    gg.toast("[x] Failed to Get Value, Tried Another Value")
    hc_method2 = true
  end
  
  if hc_method2 then
      gg.searchNumber('::false:::', gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
      local r = gg.getResults(1)
      if #r < 1 then
          gg.toast("✘ 𝐌𝐞𝐭𝐡𝐨𝐝 𝟐 𝐅𝐚𝐢𝐥𝐞𝐝")
          hc_method3 = true
          end
  end

  if hc_method3 then
    print("✖ 𝐌𝐞𝐭𝐡𝐨𝐝 𝐅𝐚𝐢𝐥𝐞𝐝")
    os.exit()
  end
  local r = gg.getResults(100)
    if limit == false then
        r[1].address = r[1].address - 2000
        end
    
    readedMem = rwmem(r[1].address, 20000)
    save(readedMem)  
    gg.clearResults()
 
 local f = io.open("/sdcard/decrypt.txt", "r")
 local content = f:read("*all")
 f:close()

 content = string.gsub(content, '[^\x00\x20-\x7E]', '\n')
 content = string.gsub(content, ' ', "")
 content = string.gsub(content, '.*%d%d%d:', '0:')
 content = string.gsub(content, ':::::::::.*', '')
 content = string.gsub(content, ':', '\n:')
 content = string.gsub(content, ':', ':\n')
 content = string.gsub(content, '\n\n', 'false\n')
 content = string.gsub(content, ':', '')
 content = string.gsub(content, '\n+', '\n')
 
 local f = io.open("/sdcard/BOOTSTRAP.txt", "w")
 f:write(content)
 f:close()

function base64decode(input)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local b64inv = {}  -- reverse table for decoding

    for i = 1, 64 do
        b64inv[string.sub(b64chars, i, i)] = i
    end

    input = string.gsub(input, '[^'..b64chars..'=]', '')

    return (input:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f='', (b64inv[x]-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(string.sub(x, i, i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local file_path = "/sdcard/BOOTSTRAP.txt"
local input_file = io.open(file_path, "r")
local output_file = io.open("/sdcard/result.txt", "w")
local lines = {}

function shouldDecrypt(decoded_text)
    return decoded_text ~= "true" and decoded_text ~= "false" and decoded_text ~= "Zxx"-- and decoded_text ~= "0"
end

local lines = {}

for line in input_file:lines() do
    local decoded_text = shouldDecrypt(line) and base64decode(line) or line
    decoded_text = string.gsub(decoded_text, "\n", "\\n")  -- Replace newline with "\n"
    table.insert(lines, decoded_text)
end


input_file:close()

for _, line in ipairs(lines) do
    output_file:write(line, "\n")
end



output_file:close()

local file = io.open("/sdcard/result.txt", "r")

local username, password, payload

for i = 1, 50 do
    local line = file:read()

    if i == 5 then
        username = line
    elseif i == 6 then
        password = line
    elseif i == 7 then
        ssh_host = line
    elseif i == 8 then
        server_port = line
    elseif i == 13 then
        payload = line
    elseif i == 15 then
        sni = line
    elseif i == 17 then
        payload_after_tls = line
    elseif i == 19 then
        proxy = line
    elseif i == 20 then
        proxy_port = line
    elseif i == 22 then
        dns = line
    elseif i == 23 then
        dns_port = line
    elseif i == 24 then
        nameserver = line
    elseif i == 25 then
        pubkey = line
    elseif i == 28 then
        notes = line
    end
end

file:close()

local output_file = io.open("/sdcard/Tls.txt", "w")

output_file:write("┌───────────────\n│𝐓𝐋𝐒 𝐓𝐔𝐍𝐍𝐄𝐋 (𝐓𝐋𝐒)\n│𝐆𝐫𝐨𝐮𝐩: t.me/mobasniff\n├───────────────\n")
output_file:write("│[</>] username : ", username, "\n")
output_file:write("│[</>] password : ", password, "\n")
output_file:write("│[</>] host : ", ssh_host, "\n")
output_file:write("│[</>] server_port : ", server_port, "\n")
output_file:write("│[</>] payload : ", payload, "\n")
output_file:write("│[</>] ssl_sni : ", sni, "\n")
output_file:write("│[</>] after_tls : ", payload_after_tls, "\n")
output_file:write("│[</>] proxy : ", proxy, "\n")
output_file:write("│[</>] proxy_port : ", proxy_port, "\n")
output_file:write("│[</>] dns : ", dns, "\n")
output_file:write("│[</>] dns_port : ", dns_port, "\n")
output_file:write("│[</>] name_server : ", nameserver, "\n")
output_file:write("│[</>] public_key : ", pubkey, "\n")
output_file:write("│[</>] notes : ", notes, "\n")
output_file:write("├───────────────\n│𝐂𝐡𝐚𝐧𝐧𝐞𝐥: t.me/mobatolls\n└───────────────")

output_file:close()

local file = io.open("/sdcard/Tls.txt", "r")

if file then

    local isi_file = file:read("*all")

    gg.alert(isi_file)
    gg.copyText(isi_file, false)

    file:close()
end
end

function NapsternetV()
  gg.clearResults()
  gg.setRanges(gg.REGION_JAVA_HEAP)
  gg.setVisible(false)
  gg.processResume()
  gg.searchNumber("h7b2276657273696f6e696e6722", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  local r = gg.getResults(1)
  if #r < 1 then
    print("en:\n⚠ No file found in memory.")
    print("❗ Import the file and try again without closing NapsternetV.\n\n")
    os.exit()
  end
  readedMem = rwmem(r[1].address, 50000)
  save(hexdecode(readedMem))
  print("✅ Successfully!\n\nFile: /sdcard/Decode-Npv4.txt")
  gg.clearResults()
end

function eV2ray()
  gg.clearResults()
  gg.setRanges(gg.REGION_JAVA_HEAP)
  gg.setVisible(false)
  gg.processResume()
  gg.searchNumber("h 7B A 9 9 22 69 6E 62 6F 75 6E 64 73 22 3A", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  local r = gg.getResults(1)
  if #r < 1 then
    print("en:\n⚠ No file found in memory.")
    print("❗ Import the file and try again without closing eV2ray.\n\n")
    os.exit()
  end
  readedMem = rwmem(r[1].address, 50000)
  save(hexdecode(readedMem))
  print("✅ Successfully!\n\nFile: /sdcard/Decode-eV2ray.txt")
  gg.clearResults()
end

function DarkTunnel()
  function rwmem(Address, SizeOrBuffer)
  assert(Address ~= nil, "[rwmem]: error, endereço fornecido é nulo.")
  
  _rw = {}

  if type(SizeOrBuffer) == "number" then
    _ = ""
    for SRD1_5_ = 1, SizeOrBuffer do
      _rw[SRD1_5_] = {
        address = Address - 1 + SRD1_5_,
        flags = gg.TYPE_BYTE
      }
    end

    for SRD1_5_, SRD1_6_ in ipairs(gg.getValues(_rw)) do
      if SRD1_6_.value == 0 and limit == true then
        return _
      end
      _ = _ .. string.format("%02X", SRD1_6_.value & 255)
    end

    return _
  end

  Byte = {}
  SizeOrBuffer:gsub("..", function(x)
    Byte[#Byte + 1] = x
    _rw[#Byte] = {
      address = Address - 1 + #Byte,
      flags = gg.TYPE_BYTE,
      value = x .. "h"
    }
  end)

  gg.setValues(_rw)
end

function hexdecode(hex)
  return (hex:gsub("%x%x", function(digits)
    return string.char(tonumber(digits, 16))
  end))
end

function hexencode(str)
  return (str:gsub(".", function(char)
    return string.format("%2x", char:byte())
  end))
end

function Dec2Hex(nValue)
  nHexVal = string.format("%X", nValue)
  sHexVal = nHexVal .. ""
  return sHexVal
end

function ToInteger(number)
  return math.floor(tonumber(number) or error("Não foi possível transmitir '" .. tostring(number) .. "' enumerar.'"))
end

function save(data)
  io.open("/sdcard/decrypt.txt", "w"):write(data)
end

limit = true
gg.clearResults()
gg.setVisible(true)
gg.setRanges(gg.REGION_JAVA_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_JAVA | gg.REGION_C_HEAP | gg.REGION_C_DATA)

local function searchAndSave(searchText)
  gg.searchNumber(searchText, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  local result = gg.getResults(1)

  if #result > 0 then
    if limit == false then
      --result[1].address = result[1].address - 3000
      result[1].address = result[1].address - 8192
    end
    --readedMem = rwmem(result[1].address, 4000)
    readedMem = rwmem(result[1].address, 10000)
    save(hexdecode(readedMem))
    return true
  end

  return false
end

local tests = {
  'h 22 6F 75 74 62 6F 75 6E 64',
  'h 7B 22 69 6E 62 6F 75 6E 64 73 22 3A 5B 7B 22 6C 69 73 74 65 6E 22 3A 22 31 32 37 2E 30 2E 30 2E 31 22 2C',
  --'h 3A 22 70 61 79 6C 6F 61 64 22 3A',
  'h 7B 22 69 6E 62 6F 75 6E 64 73 22 3A 5B 7B 22 6C 69 73 74 65 6E 22 3A 22 31 32 37 2E 30 2E 30 2E 31 22 2C',
  'h 7B 22 69 6E 62 6F 75 6E 64 73 22 3A 5B 7B 22 6C 69 73 74 65 6E 22 3A 22 31 32 37 2E 30 2E 30 2E 31 22',
  'h 3a 56 65 72 73 69 6f 6e 43 6f 64 65',
  'h 7B 22 73 73 68 43 6F 6E 66 69 67',
  'h 7B 22 69 6E 6A 65 63 74 43 6F 6E 66 69 67',
}

local addressFound = false

for i, searchText in ipairs(tests) do
  if searchAndSave(searchText) then
    addressFound = true
    break
  end
end

if not addressFound then
  gg.alert("Decryption failed. Re-import the file and run the script.")
  
  
  os.exit()
end

local f = io.open("/sdcard/decrypt.txt", "r")
local dark = f:read("*all")
f:close()

dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value') ---strings gsubs to modify keys, add key to text and place text conversation in value

dark = string.gsub(dark, "^%s*(.-)%s*$", "%1")

local f = io.open("/sdcard/decrypt.txt", "w")
f:write(dark)
f:close()

targetInfo = gg.getTargetInfo()
app = targetInfo.packageName
local label = gg.getTargetInfo().label or "N/A"

local currentDate = os.date("*t")
local data = os.date("%d/%m/%Y")

local message = "AppName: " .. label .. "\nPackage: " .. app .. "\n\n`" .. dark .. "`\n\nCurrent date: " .. data .. "\nChannel: t.me/mobatolls"

gg.alert(message, 'Copy and exit')
gg.copyText(message, false)

local f = io.open("/sdcard/decrypt.txt", "w")
f:write(message)
f:close()
gg.setVisible(false)
end

function v2rayHybrid()
  gg.clearResults()
  gg.setRanges(gg.REGION_JAVA_HEAP)
  gg.setVisible(false)
  gg.processResume()
  gg.searchNumber("h 7B A 9 9 22 69 6E 62 6F 75 6E 64 73 22 3A", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  local r = gg.getResults(1)
  if #r < 1 then
    print("en:\n⚠ No file found in memory.")
    print("❗ Import the file and try again without closing v2rayHybrid.\n\n")
    os.exit()
  end
  readedMem = rwmem(r[1].address, 50000)
  save(hexdecode(readedMem))
  print("✅ Successfully!\n\nFile: /sdcard/Decode-vhd.txt")
  gg.clearResults()
end

function ar()
function rwmem(Address, SizeOrBuffer)
  assert(Address ~= nil, "[rwmem]: error, endereço fornecido é nulo.")
  
  _rw = {}

  if type(SizeOrBuffer) == "number" then
    _ = ""
    for SRD1_5_ = 1, SizeOrBuffer do
      _rw[SRD1_5_] = {
        address = Address - 1 + SRD1_5_,
        flags = gg.TYPE_BYTE
      }
    end

    for SRD1_5_, SRD1_6_ in ipairs(gg.getValues(_rw)) do
      if SRD1_6_.value == 0 and limit == true then
        return _
      end
      _ = _ .. string.format("%02X", SRD1_6_.value & 255)
    end

    return _
  end

  Byte = {}
  SizeOrBuffer:gsub("..", function(x)
    Byte[#Byte + 1] = x
    _rw[#Byte] = {
      address = Address - 1 + #Byte,
      flags = gg.TYPE_BYTE,
      value = x .. "h"
    }
  end)

  gg.setValues(_rw)
end

function hexdecode(hex)
  return (hex:gsub("%x%x", function(digits)
    return string.char(tonumber(digits, 16))
  end))
end

function hexencode(str)
  return (str:gsub(".", function(char)
    return string.format("%2x", char:byte())
  end))
end

function Dec2Hex(nValue)
  nHexVal = string.format("%X", nValue)
  sHexVal = nHexVal .. ""
  return sHexVal
end

function ToInteger(number)
  return math.floor(tonumber(number) or error("Não foi possível transmitir '" .. tostring(number) .. "' enumerar.'"))
end

function save(data)
  io.open("/sdcard/decrypt.txt", "w"):write(data)
end

limit = true
gg.clearResults()
gg.setVisible(true)
gg.setRanges(gg.REGION_JAVA_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_JAVA | gg.REGION_C_HEAP | gg.REGION_C_DATA)

local function searchAndSave(searchText)
  gg.searchNumber(searchText, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  local result = gg.getResults(1)

  if #result > 0 then
    if limit == false then
      --result[1].address = result[1].address - 3000
      result[1].address = result[1].address - 8192
    end
    --readedMem = rwmem(result[1].address, 4000)
    readedMem = rwmem(result[1].address, 10000)
    save(hexdecode(readedMem))
    return true
  end

  return false
end

local tests = {
  'h 69 6E 62 6F 75 6E 64 73 22 3A',
  --'h 3A 22 70 61 79 6C 6F 61 64 22 3A',
  'h 7B 22 69 6E 62 6F 75 6E 64 73 22 3A 5B 7B 22 6C 69 73 74 65 6E 22 3A 22 31 32 37 2E 30 2E 30 2E 31 22 2C',
  'h 7B 22 69 6E 62 6F 75 6E 64 73 22 3A 5B 7B 22 6C 69 73 74 65 6E 22 3A 22 31 32 37 2E 30 2E 30 2E 31 22',
  'h 3a 56 65 72 73 69 6f 6e 43 6f 64 65',
}

local addressFound = false

for i, searchText in ipairs(tests) do
  if searchAndSave(searchText) then
    addressFound = true
    break
  end
end

if not addressFound then
  gg.alert("Decryption failed. Re-import the file and run the script.")
  
  
  os.exit()
end

local f = io.open("/sdcard/decrypt.txt", "r")
local dark = f:read("*all")
f:close()

dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value') ---strings gsubs to modify keys, add key to text and place text conversation in value

dark = string.gsub(dark, "^%s*(.-)%s*$", "%1")

local f = io.open("/sdcard/decrypt.txt", "w")
f:write(dark)
f:close()

targetInfo = gg.getTargetInfo()
app = targetInfo.packageName
local label = gg.getTargetInfo().label or "N/A"

local currentDate = os.date("*t")
local data = os.date("%d/%m/%Y")

local message = "AppName: " .. label .. "\nPackage: " .. app .. "\n\n`" .. dark .. "`\n\nCurrent date: " .. data .. "\nChannel: t.me/mobatolls"

gg.alert(message, 'Copy and exit')
gg.copyText(message, false)

local f = io.open("/sdcard/decrypt.txt", "w")
f:write(message)
f:close()
gg.setVisible(false)
end

function hat()
function rwmem(Address, SizeOrBuffer)
  assert(Address ~= nil, "[rwmem]: error, endereço fornecido é nulo.")
  
  _rw = {}

  if type(SizeOrBuffer) == "number" then
    _ = ""
    for SRD1_5_ = 1, SizeOrBuffer do
      _rw[SRD1_5_] = {
        address = Address - 1 + SRD1_5_,
        flags = gg.TYPE_BYTE
      }
    end

    for SRD1_5_, SRD1_6_ in ipairs(gg.getValues(_rw)) do
      if SRD1_6_.value == 0 and limit == true then
        return _
      end
      _ = _ .. string.format("%02X", SRD1_6_.value & 255)
    end

    return _
  end

  Byte = {}
  SizeOrBuffer:gsub("..", function(x)
    Byte[#Byte + 1] = x
    _rw[#Byte] = {
      address = Address - 1 + #Byte,
      flags = gg.TYPE_BYTE,
      value = x .. "h"
    }
  end)

  gg.setValues(_rw)
end

function hexdecode(hex)
  return (hex:gsub("%x%x", function(digits)
    return string.char(tonumber(digits, 16))
  end))
end

function hexencode(str)
  return (str:gsub(".", function(char)
    return string.format("%2x", char:byte())
  end))
end

function Dec2Hex(nValue)
  nHexVal = string.format("%X", nValue)
  sHexVal = nHexVal .. ""
  return sHexVal
end

function ToInteger(number)
  return math.floor(tonumber(number) or error("Não foi possível transmitir '" .. tostring(number) .. "' enumerar.'"))
end

function save(data)
  io.open("results.txt", "w"):write(data)
end

limit = false
gg.clearResults()
gg.setVisible(true)
gg.setRanges(gg.REGION_JAVA_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_JAVA | gg.REGION_C_HEAP | gg.REGION_C_DATA)

local function searchAndSave(searchText)
  gg.searchNumber(searchText, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  local results = gg.getResults(1)

  if #results > 0 then
    if not limit then
      results[1].address = results[1].address - 4500
    end
    local readedMem = rwmem(results[1].address, 6000)
    save(hexdecode(readedMem))
    return true
  end

  return false
end

local tests = {
  'h 4C 6F 2F 31 79 47 51 55 66 49 39 48 47 34 4E 55 4C',
  'h 4C 6F 2F 31 79 47 51 55 66 49 39 48 47 34 4E 55 4C',
  'h 5C 22 73 65 72 76 65 72 5F 68 6F 73 74 5C 22 3A 5C 22',
  'h 5C 22 73 65 72 76 65 72 5F 68 6F 73 74 5C 22 3A 5C 22',
}

local addressFound = false

for _, searchText in ipairs(tests) do
  if searchAndSave(searchText) then
    addressFound = true
    break
  end
end

if not addressFound then
  gg.alert("Decryption failed. Re-import the file and run the script.")
  gg.toast("𝐅𝐚𝐢𝐥𝐞𝐝")
  os.exit()
end

local f = io.open("results.txt", "r")
local content = f:read("*all")
f:close()

content = string.gsub(content, '\\"\\"' , '""')
content = string.gsub(content, '\\":\\"' , '":"')
content = string.gsub(content, '\\":' , '":')
content = string.gsub(content, '\\"' , '"')
content = string.gsub(content, '\\\\"' , '"')
content = string.gsub(content, '\\\\\\/' , '/')
content = string.gsub(content, '\\\\\\/' , '\\\\/')
content = string.gsub(content, '\\/' , '/')
content = string.gsub(content, '{"user_id":"', '{\n    "user_id": "')
content = string.gsub(content, '","access_code":"', '",\n    "access_code": "')
content = string.gsub(content, '","app_name":"', '",\n    "app_name": "')
content = string.gsub(content, '","version_alias":"', '",\n    "version_alias": "')
content = string.gsub(content, '","app_version_name":"', '",\n    "app_version_name": "')
content = string.gsub(content, '","app_version_code":', '",\n    "app_version_code": "')
content = string.gsub(content, ',"base_tunnel":', '",\n    "base_tunnel": "')
content = string.gsub(content, ',"connection_profile":"', '",\n    "connection_profile": ')
content = string.gsub(content, '{"connection_mode":"', '{\n        "connection_mode": "')
content = string.gsub(content, '{"connection_mode":', '{\n        "connection_mode": "')
content = string.gsub(content, '","server_port":', '",\n        "server_port": "')
content = string.gsub(content, ',"custom_payload":"', '",\n        "custom_payload": "')
content = string.gsub(content, '","custom_host":"', '",\n        "custom_host": "')
content = string.gsub(content, '","custom_sni":"', '",\n        "custom_sni": "')
content = string.gsub(content, '","custom_resolver":"', '",\n        "custom_resolver": "')
content = string.gsub(content, '","use_realm_host":', '",\n        "use_realm_host": "')
content = string.gsub(content, ',"preserve_sni":', '",\n        "preserve_sni": "')
content = string.gsub(content, ',"use_tcp_payload":', '",\n        "use_tcp_payload": "')
content = string.gsub(content, ',"realm_host":"', '",\n        "realm_host": "')
content = string.gsub(content, '","override_primary_host":', '",\n        "override_primary_host": ')
content = string.gsub(content, ',"primary_host":"', '",\n        "primary_host": "')
content = string.gsub(content, '","dns_primary_host":"', '",\n        "dns_primary_host": "')
content = string.gsub(content, '","primary_node":"', '",\n        "primary_node": "')
content = string.gsub(content, '"",\n    "base_tunnel": "', '",\n        "base_tunnel": "')
content = string.gsub(content, ',"isv5":', '",\n        "isv5": "')
content = string.gsub(content, ',"protextras":', '",\n        "protextras": ')
content = string.gsub(content, '{"anti_sniff":', '{\n            "anti_sniff": "')
content = string.gsub(content, ',"mobile_data":', '",\n            "mobile_data": "')
content = string.gsub(content, ',"block_root":', '",\n            "block_root": "')
content = string.gsub(content, ',"password":', '",\n            "password": "')
content = string.gsub(content, ',"password_value":"', '",\n            "password_value": "')
content = string.gsub(content, '","id_lock":', '",\n            "id_lock": "')
content = string.gsub(content, ',"id_lock_value":"', '",\n            "id_lock_value": "')
content = string.gsub(content, '","expiry":', '",\n            "expiry": "')
content = string.gsub(content, ',"expiry_value":', '",\n            "expiry_value": "')
content = string.gsub(content, '},"server_host":"', '",\n        },\n        "server_host": "')
content = string.gsub(content, '"}","receive_timer_countdown":"', '"\n    }\n    ",\n    "receive_timer_countdown": "')
content = string.gsub(content, '"}', '"\n}')


local f = io.open("results.txt", "w")
f:write(content)
f:close()

local app_version_name = content:match('"app_version_name": "(.-)"')

local start = "{\n   version_app: " .. app_version_name .. "\n"
local final = "       channel_url: t.me/mobatolls\n}"

local connection_mode = content:match('"connection_mode": "(%d+)"') or content:match('"connection_mode": "(%d+)')
local server_port = content:match('"server_port": "(%d+)')
local custom_payload = content:match('"custom_payload": "(.-)"')
local custom_host = content:match('"custom_host": "([%w%.]+)"')
local custom_sni = content:match('"custom_sni": "(%S-)"')
local custom_resolver = content:match('"custom_resolver": "([%d%.]+)"')
local use_realm_host = content:match('"use_realm_host": "(%w+)')
local preserve_sni = content:match('"preserve_sni": "(%w+)"')
local use_tcp_payload = content:match('"use_tcp_payload": "(%w+)"')
local realm_host = content:match('"realm_host": "([%w%.]+)"')
local override_primary_host = content:match('"override_primary_host": "(%w+)"')
local primary_host = content:match('"primary_host": "(%S-)"')
local dns_primary_host = content:match('"dns_primary_host": "(%S-)"')
local primary_node = content:match('"primary_node": "(%S-)"')
local base_tunnel = content:match('"base_tunnel": "(%w+)"')
local anti_sniff = content:match('"anti_sniff": "(%w+)"')
local block_root = content:match('"block_root": "(%w+)"')
local isv5 = content:match('"isv5": "(%w+)"')
local connection_profile = content:match('"connection_profile": (.-)') or "{"

local message = start

local function addKey(label, value)
  if value and value ~= "" then
    message = message .. "" .. label .. ": " .. value .. "\n"
  end
end

addKey("   connection_profile", connection_profile)
addKey("     connection_mode", connection_mode)
addKey("     server_port", server_port)
addKey("     custom_payload", custom_payload)
addKey("     custom_host", custom_host)
addKey("     custom_sni", custom_sni)
addKey("     custom_resolver", custom_resolver)
addKey("     use_tcp_payload", use_tcp_payload)
addKey("     use_realm_host", use_realm_host)
addKey("     realm_host", realm_host)
addKey("     primary_host", primary_host)
addKey("     dns_primary_host", dns_primary_host)
addKey("     primary_node", primary_node)
addKey("     base_tunnel", base_tunnel)
addKey("     isv5", isv5) 
addKey("     preserve_sni", preserve_sni)
addKey("     override_primary_host", override_primary_host)
addKey("     anti_sniff", anti_sniff)
addKey("     block_root", block_root)

if message ~= "" then
  message = message .. final
  gg.alert(message, 'Copy and exit')
  gg.copyText(message, false)
  
end

local f = io.open("/sdcard/decrypt.txt", "w")
f:write(message)
f:close()
gg.setVisible(false)
end

function sip()
gg.setVisible(true)
  function rwmem(Address, SizeOrBuffer)
    assert(Address ~= nil, "[rwmem]: error.")
    _rw = {}
    if type(SizeOrBuffer) == "number" then
      _ = ""
      do
        do
          for SRD1_5_ = 1, SizeOrBuffer do
            _rw[SRD1_5_] = {
              address = Address - 1 + SRD1_5_,
              flags = gg.TYPE_BYTE
            }
          end
        end
      end
      do
        do
          for SRD1_5_, SRD1_6_ in ipairs(gg.getValues(_rw)) do
            if SRD1_6_.value == 0 and limit == true then
              return _
            end
            _ = _ .. string.format("%02X", SRD1_6_.value & 255)
          end
        end
      end
      return _
    end
    Byte = {}
    SizeOrBuffer:gsub("..", function(x)
      Byte[#Byte + 1] = x
      _rw[#Byte] = {
        address = Address - 1 + #Byte,
        flags = gg.TYPE_BYTE,
        value = x .. "h"
      }
    end
    )
    gg.setValues(_rw)
end

  

  function save(data)
    io.open(gg.EXT_STORAGE .. "/decrypt.txt", "w"):write(data)
  end

  function hexdecode(hex)
    return (hex:gsub("%x%x", function(digits)
      return string.char(tonumber(digits, 16))
    end
    ))
  end

  gg.clearResults()
  gg.setRanges(gg.REGION_JAVA_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_JAVA | gg.REGION_C_HEAP | gg.REGION_PPSSPP | gg.REGION_C_DATA | gg.REGION_C_BSS | gg.REGION_STACK | gg.REGION_ASHMEM | gg.REGION_BAD)
  gg.setVisible(false)
  gg.searchNumber("h 6c 69 73 74 65 6e 50 6f 72 74 71 00 7e 00 01 4c 00 06", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  local r = gg.getResults(1)
  if #r < 1 then
    
    sip_2 = true
  end
  if sip_2 then
    gg.searchNumber("h6E6577746F6F6C73776F726B732E636F6D2E736F636B7369702E7574696C732E536572536F636B73495068", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      
      sip_3 = true
    end
  end
  if sip_3 then
    gg.searchNumber("h 55 70 67 72 61 64 65 3A", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      
      sip_4 = true
    end
  end
  if sip_4 then
    gg.searchNumber("h 3A 38 30 40", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      
      sip_5 = true
    end
  end
  if sip_5 then
    limit = false
    gg.searchNumber("h 7B 0A 09 09 22 69 6E 62 6F 75 6E 64", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      
      sip_6 = true
    end
  end
  if sip_6 then
    limit = false
    gg.searchNumber("h 73 70 65 65 64 79 73 73 68 2e", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      
      sip_7 = true
    end
  end
  if sip_7 then
    limit = false
    gg.searchNumber("h 3A 35 33 40", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      
      sip_8 = true
    end
  end
  if sip_8 then
    limit = false
    gg.searchNumber("h 47 45 54 20 77", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      
      sip_9 = true
    end
  end
  if sip_9 then
    limit = false
    gg.searchNumber("h 5b 63 72 6c 66 5d 48 6f 73 74 3a", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      
      sip_10 = true
    end
  end
  if sip_10 then
    limit = false
    gg.searchNumber("h 48 6f 73 74 3a 5b 72 6f 74 61 74 65 3d", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      
      sip_11 = true
    end
  end
  if sip_11 then
    limit = false
    gg.searchNumber("h 3A 34 34 33 40", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
    local r = gg.getResults(1)
    if #r < 1 then
      
      sip_12 = true
    end
  end
  if sip_12 then
    gg.toast("Sorry Nothing Found!")
    print("Close Socksip, reopen after 3secs and try again \n\n")
    os.exit()
  end
  local r = gg.getResults(9000)
  if limit == false then
    r[1].address = r[1].address - 8192
  end
  _G.readedMem = rwmem(r[1].address, 9000)
  save(hexdecode(readedMem))
  
  print("✓ Saved In: /sdcard/decrypt.txt")
  gg.clearResults()
  
  
    -- Don't edit anything unless you understand the code!
    
  local file = io.open("/sdcard/decrypt.txt", 'rb')
  local content = file:read(9000)
  file:close()
  local sshfile = io.open("/sdcard/decrypt.txt", 'rb')
  local sshcontent = sshfile:read(3400)
  sshfile:close()

local serverPayload = string.match(sshcontent, "GET%s.*TCP") or string.match(content, "POST%s.*TCP")or string.match(content, "CONNECT%s.*TCP")or string.match(content, "PUT%s.*TCP")or string.match(content, "BMOVE%s.*TCP") or string.match(content, "[A-Z]%sHTTP/.*TCP") or string.match(content, "HTTP/.*TCP") or string.match(content, "HTTP/.*%[lf%]") or string.match(content, "HTTP/.*%[crlf%]") or "___"
if not string.match(sshcontent, "GET%s.*TCP") or not string.match(sshcontent, "POST%s.*TCP") or not string.match(sshcontent, "CONNECT%s.*TCP") or string.match(sshcontent, "PUT%s.*TCP")then
local payload = {}
for i = 1, #serverPayload - 6 do
table.insert(payload, string.sub(serverPayload, i, i))
end
serverPayload = table.concat(payload,"")
else end

local SSH = string.match(sshcontent, "[%d%.%w.-]+:[%d]+@[%w%.-]+:[%w%.-]+")  or "_"
local shs = {}
for i = 1, #SSH - 1 do
table.insert(shs, SSH:sub(i,i))
end
SSH = table.concat(shs, "")


local udpserver = string.match(sshcontent, "%d+%.%d+%.%d+%.%d+t") or ""
udpserver = udpserver:gsub('t', "")

local websocket = string.match(content, "[%a%d]+%.[%w+%a]+%.xyzt  ") or ""
websocket = websocket:gsub("t  q ~", "")

local sshusern = string.match(content, "@[%w+%.-]+") or false

local udpuser = sshcontent:match('t %c[%w%.-]+-%w+') or string.match(sshcontent, "[%w%.-]+-%w+")  or "_"
local us = {}
for i = 1, #udpuser - 1 do
table.insert(us, udpuser:sub(i,i))
udpusern = table.concat(us, "")
udpusern = udpusern:gsub('t%c','')
udpusern = udpusern:gsub("%c","")
end
udpusern = udpusern or ""

local username2 = string.match(sshcontent, "t %w+q")  or "___"

udpass = string.match(sshcontent, "%Ct [%c%s]+%w+t [%c]%d") or sshcontent:match("zt [%c%s]+%w+t [%c]%d") or sshcontent:match("t [%c%s]+%w+t [%c]%d") or "___"
local sp1 = {}
for i = 4, #udpass -4 do
table.insert(sp1, udpass:sub(i,i))
end
local udpass = table.concat(sp1,"")
udpass = udpass:gsub("%c","")
udpass = udpass:gsub("%s","")

local suser = {}
sshusername = string.match(sshcontent, "t [%c]+%w+t  q ") or "___"
for i = 4, #sshusername - 5 do
table.insert(suser, sshusername:sub(i,i))
end
sshusername = table.concat(suser,"")
local sshusername2 = SSH:match("@([%w%-]+):") or false
local suser2 = {}
for i = 2, #sshusername - 1 do
table.insert(suser2, sshusername2:sub(i,i))
end
sshusername2 = table.concat(suser2, "")
local spass = {}
sshpassword = string.match(sshcontent, "t [%c]+%w+t") or "___"
for i = 4, #sshpassword - 1 do
table.insert(spass, sshpassword:sub(i,i))
end
sshpassword = table.concat(spass,"")

local sshproxy = string.match(sshcontent, "[%w%.]+:[%d]+t") or ""
sshproxy = sshproxy:gsub('t','')

local proxy = string.match(content, "%d+%.%d+%.%d+%.%d+:8080") or content:match('%d+%.%d+%.%d+%.%d+:80') or string.match(content, "%d+%.%d+%.%d+%.%d+:443")  or string.match(content, "%d+%.%d+%.%d+%.%d+:3128")

local nameserver = string.match(content,"n%w+%d?%.fibertunnel.xyzt") or  string.match(content, "nsam%d?[%w.-]+") or string.match(content, "n%w+%d?[%w.-]+") or "_"
local ns = {}
for i = 1, #nameserver - 1 do
table.insert(ns, nameserver:sub(i,i))
end 
local nameserver = table.concat(ns,"")

local serverLocation = string.match(content,"Amsterdam EU") or string.match(content,"France EU") or string.match(content,"USA %d")

local serverProtocol = string.match(content, "%u+,%u+,%u+,%u+")

local serverDNS = string.match(content, "%d+%.%d+%.%d+%.%d+:53") or ""

local hostws = string.match(content,"%U%U%d?%.fibertunnel.xyz") or string.match(content, "%A+%.%A+%.xyz") or string.match(content,"br1.fibertunnel.xyz") or string.match(content,"br2.fibertunnel.xyz") or string.match(content,"gr1.fibertunnel.xyz") or string.match(content,"ca1.fibertunnel.xyz") or string.match(content,"uk1.fibertunnel.xyz") or string.match(content,"uk2.fibertunnel.xyz") or string.match(content,"fr1.fibertunnel.xyz") or string.match(content,"fr2.fibertunnel.xyz") or string.match(content,"am1.fibertunnel.xyz")

local pubkey = string.match(content, "@[%d%U]+a") or ""

local pkey = string.match(pubkey, "[%d%a]+") or ""

local notes = content:match("<.*>.*</[%w%p]+>") or content:match("<[%w%p%s]+>.*</[%w%p]+>")

local sni = content:match("[%w]+%.[%w]+%.[%w]+%.[%w]+t") or content:match("[%w]+%.[%w]+%.[%w]+t") or content:match("[%w]+%.[%w]+t") or "_"
local sn = {}
for i = 1, #sni - 1 do
table.insert(sn, sni:sub(i,i))
end 
sni = table.concat(sn, "")

local key = content:match("[%w][%w%p%a]+=")

local mode = {"Request/Single Tunnel","Custom SSH","Custom UDP","DNS","Custom Websocket",}
local active_mode = ""
if #serverPayload > 10 then
active_mode = mode[1]
elseif #udpserver > 7 and #udpusern > 5 or #udpass > 6 then
active_mode = mode[3]
elseif #SSH > 7 and sshusername > 3 and sshpassword > 3 then
active_mode = mode[2]
elseif #serverDNS > 6 and  #pkey > 10 then
active_mode = mode[4]
elseif  #sni > 6 and #serverPayload < 10 and #udpserver < 6 then
active_mode = mode[5]
else
active_mode = "";
end

local result = {
	[1] = {
    ['NAME'] = "│◉ sock_mode",
    ['DATA'] = active_mode
  },
  [2] = {
    ['NAME'] = "│◉ payload",
    ['DATA'] = serverPayload
  },
  [3] = {
    ['NAME'] = "│◉ server_udp",
    ['DATA'] = udpserver 
  },
  [6] = {
    ['NAME'] = "│◉ server",
    ['DATA'] = SSH
  },
  [4] = {
    ['NAME'] = "│◉ username_udp",
    ['DATA'] = udpusern
  },
  [5] = {
    ['NAME'] = "│◉ password_udp",
    ['DATA'] = udpass
  },
    [7] = {
    ['NAME'] = "│◉ username",
    ['DATA'] = sshusername
  },
    [8] = {
    ['NAME'] = "│◉ password",
    ['DATA'] = sshpassword
  },
  [9] = {
    ['NAME'] = "│◉ proxy",
    ['DATA'] = sshproxy
  },
  [10] = {
    ['NAME'] = "│◉ proxy_port",
    ['DATA'] = proxy
  },
  [11] = {
    ['NAME'] = "│◉ host_websocket",
    ['DATA'] = hostws or websocket
  },
  [12] = {
    ['NAME'] = "│◉ location", 
    ['DATA'] = serverLocation
  },
  [13] = {
    ['NAME'] = "│◉ protocol", 
    ['DATA']= serverProtocol
  },
  [14] = {
    ['NAME'] = "│◉ ssl_sni",
     ['DATA'] = sni
    },
  [15] = {
    ['NAME'] = "│◉ server_dn", 
    ['DATA'] = serverDNS
  },
  [16] = {  
["NAME"] = "│◉ name_server",   
 ["DATA"] = nameserver
},
[17] = { 
["NAME"] = "│◉ public_key", 
['DATA'] = pkey
},
 [19] = { 
["NAME"] = "│◉ notes" , 
['DATA'] = notes
},
[18] = { 
["NAME"] = "│◉ server_key" , 
['DATA'] = key
},
 
  }
  
      local message = "┌─────────────────\n│𝐒𝐎𝐂𝐊𝐒𝐈𝐏 (𝐒𝐈𝐏)\n│𝐆𝐫𝐨𝐮𝐩: t.me/mobasniff\n├───────────────\n"
      for index, keys in ipairs(result) do
        if result[index] and result[index]['DATA'] then 
          local names = result[index]['NAME']
          local value = result[index]['DATA']
  
          message = message..names.." : "..value.."\n"
           end
            end

            message = message.."├───────────────\n│𝐂𝐡𝐚𝐧𝐧𝐞𝐥: t.me/mobatolls \n└───────────────"
      gg.alert(message, "COPY TO CLIPBOARD")
      io.open('/sdcard/socksip.txt', 'w'):write(message)
      gg.copyText(message, false)
      gg.toast("by MOBASNIFF")
   --   print("Pubkey value: "..result[16]['DATA'])
    save(hexdecode(readedMem))
  gg.clearResults()
end

function nm()
function rwmem(Address, SizeOrBuffer)
  assert(Address ~= nil, "[rwmem]: error, endereço fornecido é nulo.")
  
  _rw = {}

  if type(SizeOrBuffer) == "number" then
    _ = ""
    for SRD1_5_ = 1, SizeOrBuffer do
      _rw[SRD1_5_] = {
        address = Address - 1 + SRD1_5_,
        flags = gg.TYPE_BYTE
      }
    end

    for SRD1_5_, SRD1_6_ in ipairs(gg.getValues(_rw)) do
      if SRD1_6_.value == 0 and limit == true then
        return _
      end
      _ = _ .. string.format("%02X", SRD1_6_.value & 255)
    end

    return _
  end

  Byte = {}
  SizeOrBuffer:gsub("..", function(x)
    Byte[#Byte + 1] = x
    _rw[#Byte] = {
      address = Address - 1 + #Byte,
      flags = gg.TYPE_BYTE,
      value = x .. "h"
    }
  end)

  gg.setValues(_rw)
end

function hexdecode(hex)
  return (hex:gsub("%x%x", function(digits)
    return string.char(tonumber(digits, 16))
  end))
end

function hexencode(str)
  return (str:gsub(".", function(char)
    return string.format("%2x", char:byte())
  end))
end

function Dec2Hex(nValue)
  nHexVal = string.format("%X", nValue)
  sHexVal = nHexVal .. ""
  return sHexVal
end

function ToInteger(number)
  return math.floor(tonumber(number) or error("Não foi possível transmitir '" .. tostring(number) .. "' enumerar.'"))
end

function save(data)
  io.open("/sdcard/decrypt.txt", "w"):write(data)
end

limit = true
gg.clearResults()
gg.setVisible(true)
gg.setRanges(gg.REGION_JAVA_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_JAVA | gg.REGION_C_HEAP | gg.REGION_C_DATA)

local function searchAndSave(searchText)
  gg.searchNumber(searchText, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  local result = gg.getResults(1)

  if #result > 0 then
    if limit == false then
      --result[1].address = result[1].address - 3000
      result[1].address = result[1].address - 8192
    end
    --readedMem = rwmem(result[1].address, 4000)
    readedMem = rwmem(result[1].address, 10000)
    save(hexdecode(readedMem))
    return true
  end

  return false
end

local tests = {
  'h 69 6E 62 6F 75 6E 64 73 22 3A',
  --'h 3A 22 70 61 79 6C 6F 61 64 22 3A',
  'h 7B 22 69 6E 62 6F 75 6E 64 73 22 3A 5B 7B 22 6C 69 73 74 65 6E 22 3A 22 31 32 37 2E 30 2E 30 2E 31 22 2C',
  'h 7B 22 69 6E 62 6F 75 6E 64 73 22 3A 5B 7B 22 6C 69 73 74 65 6E 22 3A 22 31 32 37 2E 30 2E 30 2E 31 22',
  'h 3a 56 65 72 73 69 6f 6e 43 6f 64 65',
}

local addressFound = false

for i, searchText in ipairs(tests) do
  if searchAndSave(searchText) then
    addressFound = true
    break
  end
end

if not addressFound then
  gg.alert("Decryption failed. Re-import the file and run the script.")
  
  
  os.exit()
end

local f = io.open("/sdcard/decrypt.txt", "r")
local dark = f:read("*all")
f:close()

dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value') ---strings gsubs to modify keys, add key to text and place text conversation in value

dark = string.gsub(dark, "^%s*(.-)%s*$", "%1")

local f = io.open("/sdcard/decrypt.txt", "w")
f:write(dark)
f:close()

targetInfo = gg.getTargetInfo()
app = targetInfo.packageName
local label = gg.getTargetInfo().label or "N/A"

local currentDate = os.date("*t")
local data = os.date("%d/%m/%Y")

local message = "AppName: " .. label .. "\nPackage: " .. app .. "\n\n`" .. dark .. "`\n\nCurrent date: " .. data .. "\nChannel: t.me/mobatolls"

gg.alert(message, 'Copy and exit')
gg.copyText(message, false)

local f = io.open("/sdcard/decrypt.txt", "w")
f:write(message)
f:close()
gg.setVisible(false)
end

function json()
function rwmem(Address, SizeOrBuffer)
  assert(Address ~= nil, "[rwmem]: error, endereço fornecido é nulo.")
  
  _rw = {}

  if type(SizeOrBuffer) == "number" then
    _ = ""
    for SRD1_5_ = 1, SizeOrBuffer do
      _rw[SRD1_5_] = {
        address = Address - 1 + SRD1_5_,
        flags = gg.TYPE_BYTE
      }
    end

    for SRD1_5_, SRD1_6_ in ipairs(gg.getValues(_rw)) do
      if SRD1_6_.value == 0 and limit == true then
        return _
      end
      _ = _ .. string.format("%02X", SRD1_6_.value & 255)
    end

    return _
  end

  Byte = {}
  SizeOrBuffer:gsub("..", function(x)
    Byte[#Byte + 1] = x
    _rw[#Byte] = {
      address = Address - 1 + #Byte,
      flags = gg.TYPE_BYTE,
      value = x .. "h"
    }
  end)

  gg.setValues(_rw)
end

function hexdecode(hex)
  return (hex:gsub("%x%x", function(digits)
    return string.char(tonumber(digits, 16))
  end))
end

function hexencode(str)
  return (str:gsub(".", function(char)
    return string.format("%2x", char:byte())
  end))
end

function Dec2Hex(nValue)
  nHexVal = string.format("%X", nValue)
  sHexVal = nHexVal .. ""
  return sHexVal
end

function ToInteger(number)
  return math.floor(tonumber(number) or error("Não foi possível transmitir '" .. tostring(number) .. "' enumerar.'"))
end

function save(data)
  io.open("/sdcard/decrypt.txt", "w"):write(data)
end

limit = true
gg.clearResults()
gg.setVisible(true)
gg.setRanges(gg.REGION_JAVA_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_JAVA | gg.REGION_C_HEAP | gg.REGION_C_DATA)

local function searchAndSave(searchText)
  gg.searchNumber(searchText, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  local result = gg.getResults(1)

  if #result > 0 then
    if limit == false then
      --result[1].address = result[1].address - 3000
      result[1].address = result[1].address - 8192
    end
    --readedMem = rwmem(result[1].address, 4000)
    readedMem = rwmem(result[1].address, 10000)
    save(hexdecode(readedMem))
    return true
  end

  return false
end

local tests = {
  'h 7B 22 50 61 79 6C 6F 61 64',
  'h 22 53 65 72 76 65 72 53 53 48',
  'h 7B 22 64 6E 73 22 3A 7B 22 68 6F 73',
  'h 69 6E 62 6F 75 6E 64 73 22 3A',
  'h 73 74 72 69 6E 67 20 6E 61 6D 65 3D 22 53 53 48 5F 41 55 54 48 5F 44 41 54 41 22 3E 76',
  'h 22 73 65 72 76 65 72',
  'h 7B 22 61 62',
  'h 22 55 73 65 72',
  'h 7B 22 7A',
  'h 22 4E 61 6D 65',
}

local addressFound = false

for i, searchText in ipairs(tests) do
  if searchAndSave(searchText) then
    addressFound = true
    break
  end
end

if not addressFound then
  gg.alert("Decryption failed. Re-import the file and run the script.")
  
  
  os.exit()
end

local f = io.open("/sdcard/decrypt.txt", "r")
local dark = f:read("*all")
f:close()

dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value')
dark = string.gsub(dark, 'text', 'value') ---strings gsubs to modify keys, add key to text and place text conversation in value

dark = string.gsub(dark, "^%s*(.-)%s*$", "%1")

local f = io.open("/sdcard/decrypt.txt", "w")
f:write(dark)
f:close()

targetInfo = gg.getTargetInfo()
app = targetInfo.packageName
local label = gg.getTargetInfo().label or "N/A"

local currentDate = os.date("*t")
local data = os.date("%d/%m/%Y")

local message = "AppName: " .. label .. "\nPackage: " .. app .. "\n\n" .. dark .. "\n\nDate/Time: " .. data .. "\nChannel: t.me/mobatolls"

gg.alert(message, 'Copy and exit')
gg.copyText(message, false)

local f = io.open("/sdcard/decrypt.txt", "w")
f:write(message)
f:close()
gg.setVisible(false)
end

if app == "com.evozi.injector" then
  HttpInjector()
elseif app == "com.evozi.injector.lite" then
  HttpInjector()
elseif app == "xyz.easypro.httpcustom" then
  UDPNEW()
elseif app == "xyz.easypro.httpcustom" then
  HTTPCustom()
elseif app == "com.tlsvpn.tlstunnel" then
  TLSTunnel()
elseif app == "com.napsternetlabs.napsternetv" then
  NapsternetV()
elseif app == "dev.epro.e_v2ray" then
  eV2ray()
elseif app == "net.darktunnel.app" then
  DarkTunnel()
elseif app == "com.slipkprojects.sksplus" then
  SocksHttpPlus()
elseif app == "com.v2ray.hybrid" then
  v2rayHybrid()
elseif app == "com.noobz.id.noobzvpn" then
  noobzvpn()
elseif app == "com.artunnel57" then
  ar()
elseif app == "com.hatunnel.plus" then
  hat()
elseif app == "com.newtoolsworks.sockstunnel" then
  sip()
elseif app == "com.netmod.syna" then
  nm()
elseif json() then
else
print("")
end
gg.clearResults()
print([[⠛⠛⣿⣿⣿⣿⣿⡷⢶⣦⣶⣶⣤⣤⣤⣀⠀⠀⠀
 ⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀
 ⠀⠀⠀⠉⠉⠉⠙⠻⣿⣿⠿⠿⠛⠛⠛⠻⣿⣿⣇⠀
 ⠀⠀⢤⣀⣀⣀⠀⠀⢸⣷⡄⠀⣁⣀⣤⣴⣿⣿⣿⣆
 ⠀⠀⠀⠀⠹⠏⠀⠀⠀⣿⣧⠀⠹⣿⣿⣿⣿⣿⡿⣿
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠿⠇⢀⣼⣿⣿⠛⢯⡿⡟
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠦⠴⢿⢿⣿⡿⠷⠀⣿⠀
 ⠀⠀⠀⠀⠀⠀⠀⠙⣷⣶⣶⣤⣤⣤⣤⣤⣶⣦⠃⠀
 ⠀⠀⠀⠀⠀⠀⠀⢐⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀
 ⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀
 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⢿⣿⣿⣿⣿⠟⠁


telegram t.me/mobasniff
]])
os.exit()