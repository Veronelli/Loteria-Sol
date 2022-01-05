// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./safe-math.sol";
import "./erc20.sol";



contract loteria{
    // Implementar libreria
    using SafeMath for uint;

    // Instanciar contracto Token
    ERC20Basic private token;
    
    // Direcciones...
    address public owner;
    address public contrato = address(this);

    // Numero de tokens creados...
    uint public tokensCreados=1000000;


    constructor() public {
        token = new ERC20Basic(tokensCreados);
        owner = msg.sender;
    }

    // -------------- Modifier --------------//

    // Verificar el si es el propietario
    modifier isOwner(address _owner){
        require(owner == _owner,"No eres el owner");
        _;
    }

    // -------------- Tokens -------------- //

    // Precio de los tokens
    function precioToken(uint _numToken) internal pure returns(uint){
        return ((_numToken)*1 ether)/2 ;
    }

    function cantidadTokens(uint pago) internal pure returns(uint){
        return ((pago)/1000000000000000000)*2;
    }

    // Balance del contrato
    function contractBalance()public view returns(uint) {
        return token.balanceOf(contrato);
    }

    // Balance del un cliente
    function balanceOf(address _cliente)public view returns(uint){
        return token.balanceOf(_cliente);
    }
    // Generar nuevos tokens
    function generarTokens(uint _numTokens) public isOwner(msg.sender) {
        token.increaseTotalSupply(_numTokens);
        tokensCreados = tokensCreados.add(_numTokens);

    }

    //Comprar nuevos tokens
    function comprarTokens() public payable{
        uint pago = msg.value;
        uint numTokens = cantidadTokens(pago);
        require(numTokens <= contractBalance(),"No hay suficientes tokens");
        
        token.transfer(msg.sender,numTokens);

    }

    function Bote() public view returns(uint){
        return balanceOf(owner);
    }

    // -------------- Loteria --------------//
    // Precio del token
    uint public precioBoleto = 5;

    // Mapping relaciona el boleto con el cliente
    mapping(address=>uint[])idPersona_boleto;

    // Mapping asociado al ganador
    mapping (uint => address) ADN_boleto;

    uint randNonce = 0;
    uint[] boletosComprados;


    // Eventos
    event boleto_comprado(uint,address);
    event boleto_gandor(uint);
    event tokens_devueltos(uint,address);

    // Calcular precio
    function calcularBoletos(uint boletos) public returns(uint){
        return boletos*precioBoleto;
    }

    // Funcion comprar boletos
    function comprarBoletos(uint boletos)public {
        uint costo = calcularBoletos(boletos);
        require(costo <= balanceOf(msg.sender),"No tienes sufientes tokens");
        token.transferLoteria(msg.sender, owner, costo);

        for(uint i = 0;i < boletos; i++){
            uint random = uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % 10000;
            idPersona_boleto[msg.sender].push(random);
            boletosComprados.push(random);
            ADN_boleto[random] = msg.sender;
            randNonce++;
        }

        emit boleto_comprado(boletos,msg.sender);
    }

    // Ver boletos de los clientes
    function verBoletos()public view returns(uint[] memory){
        return idPersona_boleto[msg.sender];
    }

    // Ver el ganador
    function GenerarGandor() public isOwner(msg.sender){
        require(boletosComprados.length > 2, "No se ha vendido mas de 2 boletos");
        uint longitud = boletosComprados.length;
        uint pocision_array = uint(uint(keccak256(abi.encodePacked(block.timestamp)))%longitud);


        uint eleccion = boletosComprados[pocision_array];
        emit boleto_gandor(eleccion);

        address direccion_ganadora = ADN_boleto[eleccion];
        token.transferLoteria(owner, direccion_ganadora, Bote());

    }

    // Conversion de tokens
    function devolverTokens(uint _numTokens) public  {
        require(_numTokens > 0, "Debes ingresar tokens mayores a 0");
        require(_numTokens <= balanceOf(msg.sender), "Necesitas mas tokens");

        token.transferLoteria(msg.sender, address(this), _numTokens);
        payable(msg.sender).transfer(precioToken(_numTokens));
        emit tokens_devueltos(_numTokens,msg.sender);

    }

}