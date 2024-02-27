
# Descripción
El objetivo principal de este proyecto es familiarizarse con el desarrollo de contratos inteligentes utilizando Solidity y Remix. 
Se exploran conceptos como la creación de contratos, pruebas, scripts y el despliegue en un entorno local

# Contenido

# Introducción a los Créditos de Carbono
Los créditos de carbono son certificados que representan la reducción de emisiones de
gases de efecto invernadero. Cada crédito equivale a una tonelada de CO2 (dióxido de
carbono) no emitida a la atmósfera. Estos créditos surgen de proyectos que reducen, evitan
o capturan emisiones. Se utilizan en mercados de carbono, donde empresas o gobiernos los
compran para compensar sus propias emisiones de CO2 y cumplir con regulaciones
ambientales o metas de sostenibilidad.
Un ejemplo de mercado es https://www.ecoregistry.io, que certifica proyectos de reducción
de emisiones y facilita el comercio de créditos.

# Flujo de la DApp ClimateCoin

1. Certificación del Proyecto: Un desarrollador, por ejemplo, instala paneles solares en
Colombia (ver https://www.ecoregistry.io/projects/151 como ejemplo). Ecoregistry verifica y
certifica la instalación, emitiendo 297.565 créditos de carbono al desarrollador.

3. Creación del NFT: El desarrollador nos transfiere esos créditos a nuestra cuenta en
ecoregistry.io. Verificamos la recepción y emitimos un NFT ERC-721, representando el
proyecto en la blockchain. Este NFT incluye detalles como el nombre del proyecto, total de
créditos, y una URL del proyecto.

4. Intercambio por ClimateCoin: El desarrollador puede intercambiar este NFT por nuestro
token fungible ERC-20, el ClimateCoin (CC), a razón de 1 CC por crédito de carbono. El NFT
pasa a ser propiedad de nuestro contrato inteligente. Nosotros nos quedamos una pequeña
fee en forma de ClimateCoin.

5. Comercio en Mercados Externos: El desarrollador puede vender sus CC en mercados de
terceros.

6. Quema de ClimateCoin: Cualquier poseedor de CC puede “quemar” sus tokens, y nuestro
contrato inteligente quemará un NFT correspondiente. Este proceso simboliza el "uso" o
"retiro" de créditos de carbono del mercado, permitiendo a empresas compensar su huella de
carbono.
Este sistema vincula proyectos de reducción de emisiones con un activo digital
(ClimateCoin), facilitando su comercio y trazabilidad en la blockchain.


# Objetivo de la Práctica

Los estudiantes desarrollarán una DApp en Solidity que implemente este flujo de trabajo,
comprendiendo el impacto ambiental y la utilidad de los créditos de carbono, así como las
posibilidades que ofrece la tecnología blockchain para mejorar la transparencia y eficiencia
en el comercio de estos créditos.

# Detalles de la implementación

1. Inicialización y Despliegue del ERC-20 ClimateCoin
- Crear un contrato inteligente para ClimateCoin siguiendo el estándar ERC-20.
- En el constructor del contrato de gestión, se despliega el contrato ERC-20 ClimateCoin.

2. Función para Mintear NFT (ERC-721)
- Función `mintNFT`:
- Parámetros: `uint256 credits`, `string memory projectName`, `string memory projectURL`,
`address developerAddress`.
- Solo puede ser llamada por el creador del contrato.
- Desplegar un ERC721 para crear el NFT con los datos proporcionados.
- Asignar el NFT directamente a `developerAddress`.
- Emitir un evento `NFTMinted` con detalles relevantes.
  
3. Función de Intercambio de NFT por ClimateCoins con Sistema de
Fees
- Variables de Fee:
- Agregar `uint256 public feePercentage` para almacenar el porcentaje de la fee.
- Agregar una función `setFeePercentage(uint256 newFeePercentage)` que permita al
propietario del contrato actualizar `feePercentage`.
- Función `exchangeNFTForCC`:
- Parámetros: `address nftAddress`, `uint256 nftId`.
- El NFT se transfiere al contrato.
- Transferir la cantidad final de ClimateCoins al msg.sender.
- Enviar las fees al creador del contrato.
- Emitir un evento `NFTExchanged` con detalles de la transacción.
  
4. Función de Quema de ClimateCoins y NFT
- Función `burnCCAndNFT`:
- Parámetros: `uint256 ccAmount`.
- Elegir un NFT de la colección del contrato con valor equivalente a `ccAmount`.
- Destruir el NFT seleccionado junto a los CC.
- Emitir evento `CCBurn` con los detalles del quemado.
Gestión de Errores y Eventos
- Manejo de Excepciones: Implementar las verificaciones necesarias para asegurar el
correcto funcionamiento de la dApp y evitar ser hackeados.
- Eventos: Emitir eventos para facilitar la trazabilidad y el monitoreo en la blockchain.
