// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @dev Implementación de la interfaz {IERC20}.
 *
 * Esta implementación es independiente de la forma en que se crean los tokens. Esto significa
 * que se debe agregar un mecanismo de suministro en un contrato derivado usando {_mint}.
 *
 * CONSEJO: Para obtener un artículo detallado, consulte nuestra guía.
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[Cómo
 * implementar mecanismos de suministro].
 *
 * El valor predeterminado de {decimales} es 18. Para cambiar esto, debes anular
 * esta función para que devuelva un valor diferente.
 *
 * Hemos seguido las pautas generales de OpenZeppelin Contracts: las funciones se revierten
 * en lugar de devolver "falso" en caso de error. Este comportamiento es, sin embargo,
 * convencional y no entra en conflicto con las expectativas de ERC20
 * aplicaciones.
 *
 * Además, se emite un evento {Approval} en las llamadas a {transferFrom}.
 * Esto permite que las aplicaciones reconstruyan la asignación para todas las cuentas solo
 * escuchando dichos eventos. Es posible que otras implementaciones del EIP no emitan
 * estos eventos, ya que no lo exige la especificación.
 * IMPORTANTE: No creamos mappings para guardar los tokens CC porque ya se guardan en el contrato original ERC20
 */
contract ClimateCoin is ERC20 {

    constructor(uint256 initialSupply) ERC20("ClimateCoin", "CC") {
        _mint(msg.sender, initialSupply);
    }
}

/**
 * @dev Implementación de https://eips.ethereum.org/EIPS/eip-721[ERC721] Estándar de token no fungible, incluido
 * la extensión Metadata, pero sin incluir la extensión Enumerable, que está disponible por separado como
 * {ERC721Enumerable}.

 * CONSEJO: Para obtener un artículo detallado, consulte nuestra guía.
 * https://docs.openzeppelin.com/contracts/4.x/erc721
 * implementar mecanismos de suministro].
 
 * NOTA: El token MyNFT tiene la funcion mintNFT que es donde se crea el token con la cantidad que queramos y van
 * a la dirrecion del desarrollador. Despues se emite un evento con la cantidad de creditos, nombre proyecto,
 * URL del sitio y su direccion.
 * Introducimos la funcion de quemado para usarlo en el contrato de intercambioCC ya que la propia del ERC721 son de
 * visibilidad internal y seria solo para este contrato MyNFT y nosotros ademas lo queremos para intercambioCC,creamos
 * una nueva funcion burn de quemado como external para que podamos heredarla en este contrato.
 * IMPORTANTE: No creamos mappings para guardar los tokens MyNFT porque ya se guardan en el contrato original ERC721
 */
 
contract MyNFT is ERC721 {

    event NFTMinted(uint256 credits, string projectName, string projectURL, address developerAddress);

    constructor() ERC721("MyNFT", "MNFT") {}

    function mintNFT(uint256 credits, string memory projectName, string memory projectURL, address developerAddress) external {
        _mint(developerAddress, credits);
        emit NFTMinted(credits, projectName, projectURL, developerAddress);
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }

}

/**
 * @dev En este contrato no hacemos ninguna Implementación, lo hacemos todo de manera manual
 * NOTA: Creanos las variables publicas al ser un contrato de intercambio. climateCoin y myNFTContract
 * son variables que guardan la interfaz de los contratos heredados ClimateCoin y MyNFT, que son estos con lo que vamos a trabajar.

 * Emitimos 3 eventos : Actualizacion de la tarifa(fess), el intercambio y la quema de los token.
 *
 * Guardamos en el mapping la cantidad de tokens que se transfieren tanto CC como NFT.
 *
 * En el contructor tenemos la direccion de quien pose los CC y de quien posee los NFT y tambien inicializamos la tarifa al 1%.
 *
 * Creamos por seguridad un modifier OnlyOwner darle seguridad a ciertas funciones y asegurarnos que el remitente es el dueño 
 * de esos tokens.
 *
 * Añadimos la funcion setFeePercentage que actualiza el porcentaje de la tarifa y emite un evento al realizar la tarea.
 *
 * La funcion exchangeNFTForCC, es la funcion con la que vamos hacer los intercambios de tokens. Primero aseguramos con un llamada
 * de que el emisor de los NFT solo puede cambiar sus propios tokens por seguridad, si es asi sigue sino se revierte la transacion.
 * Con la funcion safeTransferFrom heredad del token 721 realizamos la transferencia de los NFT.
 * Creamos 3 variables tipo numerico para almacenar las operaciones , la primera almacena esta funcion interna calculateCCAmount que nos
 * calcula la cantidad de CC que se debe transferir por el NFT. La segunda calcula el porcentaje de fee que se debe aplicar y la tercera
 * es la cantidad de tokens que se transfiere.
 * Pasamos a la parte del CC para realizar la transferencia direccion del emisor y la cantidad final calculada anteriormente, amountToTransfer.
 * Nos aseguramos que sea el dueño de esos CC quien hace la transacion con el porcentaje calculado de fee anteriormente.
 * Guardamos este total amountToTransfer en nuestro mapping _balances y emitimos el evento NFTExchanged.
 *
 * La funcion burnCCAndNFT,que sirbe para el quemado de los tokens.Recibe como parametros ccAmount y la cantidad de nftId a quemar. 
 * Por seguridad ya tiene que ser una funcion publica como la funcion exchangeNFTForCC, tenemos que añadirle una llamada de que el emisor 
 * de los NFT solo puede cambiar sus propios tokens.
 * Realizamos la transferencia de CC a la direccion con la cantidad a quemar y al mismo tiempo quemamos el nftId.
 * Finalmente emitimos el evento del quemado.
 */

contract IntercambioCC { 

    address public owner;
    uint256 public feePercentage;
    ClimateCoin public climateCoin;
    MyNFT public myNFTContract;

    event FeePercentageUpdated(uint256 newFeePercentage);
    event NFTExchanged(address indexed from, address indexed to, uint256 indexed tokenId, uint256 ccAmount, uint256 feeAmount);
    event CCBurn(address indexed burner, uint256 ccAmount, uint256 tokenId);

    mapping (uint256 => uint256) private _balances;

    constructor(address _climateCoin, address _myNFTContract)  {
        climateCoin = ClimateCoin(_climateCoin);
        myNFTContract = MyNFT(_myNFTContract);
        feePercentage = 1;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "only owner");
        _;
    }

    function setFeePercentage(uint256 newFeePercentage) public onlyOwner {
        feePercentage = newFeePercentage;
        emit FeePercentageUpdated(newFeePercentage);
    }

    function exchangeNFTForCC(uint256 nftId) public  {
        require(myNFTContract.ownerOf(nftId) == msg.sender, "Solo puedes intercambiar tus propios NFT");
        
        myNFTContract.safeTransferFrom(msg.sender, address(this), nftId);
        uint256 ccAmount = calculateCCAmount(nftId);
        uint256 feeAmount = (ccAmount * feePercentage) / 100;
        uint256 amountToTransfer = ccAmount - feeAmount;

        climateCoin.transfer(msg.sender, amountToTransfer);
        climateCoin.transfer(owner, feeAmount);
        _balances[nftId] = amountToTransfer;
        emit NFTExchanged(msg.sender, owner, nftId, amountToTransfer, feeAmount);
    }

    function burnCCAndNFT(uint256 ccAmount, uint256 nftId) public  { 
        require(myNFTContract.ownerOf(nftId) == msg.sender, "Solo puedes intercambiar tus propios NFT");
        climateCoin.transferFrom(msg.sender, address(this), ccAmount);
        myNFTContract.burn(nftId);
        emit CCBurn(msg.sender, ccAmount, nftId);
    }

    function calculateCCAmount(uint256 nftId) internal pure returns (uint256) {
        // Implementa aquí la lógica para calcular la cantidad de ClimateCoins que se deben transferir por el NFT
        return nftId;
    }
}






