/**
 * @description       : Rest API tratar requisição com objeto único
 * @author            : Jefferson Martins
 * @group             : 
 * @last modified on  : 12-30-2021
 * @last modified by  : Jefferson Martins
**/
@RestResource(urlMapping='/Carro/*')
global with sharing class CarroRestAPI {

    
    /**
    * @description : Retorna retorna carro de acordo com a placa informada
    * @author Jefferson Martins | 12-29-2021 
    * @return Map<String,String> 
    **/
    @HttpGet
    global static Map<String,String> doGet() {
        Map<String,String> result = new Map<String,String>();

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String placa = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<Carro__c> carroList = [SELECT Id, Name, Chassi__c, 
                                        Combustivel__c, Renavam__c, Cor__c, 
                                        Modelo__c, Fabricante__r.Name, Placa__c,
                                        SituacaoVeiculo__c, Quilometragem__c
                                FROM Carro__c WHERE Placa__c = :placa];
        
        
        if (carroList.size() == 0) {
            RestContext.response.statusCode = 404;
        } else {
            result.put('placa', carroList[0].Placa__c);
            result.put('chassi', carroList[0].Chassi__c);
            result.put('combustivel', carroList[0].Combustivel__c);
            result.put('renavam', carroList[0].Renavam__c);
            result.put('cor', carroList[0].Cor__c);
            result.put('fabricante', carroList[0].Fabricante__r.Name);
            result.put('situacaoVeiculo', carroList[0].SituacaoVeiculo__c);
            result.put('quilometragem', String.valueOf(carroList[0].Quilometragem__c));
            RestContext.response.statusCode = 200;
        }
        

        return result;
    }

    /**
    * @description : Validar campos do carro
    * @author Jefferson Martins | 12-29-2021 
    * @param chassi 
    * @param combustivel 
    * @param renavam 
    * @param cor 
    * @param modelo 
    * @param placa 
    * @param situacaoVeiculo 
    * @param quilometragem 
    * @return Map<String, String> 
    **/
    private static Map<String,String> validarCampos(String chassi, String combustivel, 
                                            String renavam, String cor, String modelo, 
                                            String placa, String situacaoVeiculo, Decimal quilometragem) {
        
        Map<String,String> validacoes = new Map<String,String>();
        
        if (placa.length() != Carro__c.Placa__c.getDescribe().getLength()) {
            validacoes.put('Placa', 'Placa inválida, deve estar no formato AAA1234');            
        }
        if (chassi.length() != Carro__c.Chassi__c.getDescribe().getLength()) {
            validacoes.put('Chassi', 'Tamanho inválido, deve ter ' + Carro__c.Chassi__c.getDescribe().getLength() + ' caracteres.');
        }
        if (renavam.length() != Carro__c.Renavam__c.getDescribe().getLength()) {
            validacoes.put('Renavam', 'Renavam inválido, deve ter ' + Carro__c.Renavam__c.getDescribe().getLength() + ' caracteres.');
        }
        if (combustivel.length() > Carro__c.Combustivel__c.getDescribe().getLength()) {
            validacoes.put('Combustível', 'Tamanho inválido, deve ter no máximo ' + Carro__c.Combustivel__c.getDescribe().getLength() + ' caracteres.');
        }
        if (cor.length() > Carro__c.Cor__c.getDescribe().getLength()) {
            validacoes.put('Cor', 'Tamanho inválido, deve ter no máximo ' + Carro__c.Cor__c.getDescribe().getLength() + ' caracteres.');
        }
        if (modelo.length() > Carro__c.Modelo__c.getDescribe().getLength()) {
            validacoes.put('Modelo', 'Tamanho inválido, deve ter no máximo ' + Carro__c.Modelo__c.getDescribe().getLength() + ' caracteres.');
        }
        if (situacaoVeiculo.length() > Carro__c.SituacaoVeiculo__c.getDescribe().getLength()) {
            validacoes.put('Situação Veículo', 'Tamanho inválido, deve ter no máximo ' + Carro__c.SituacaoVeiculo__c.getDescribe().getLength() + ' caracteres.');
        }

        return validacoes;
    }

    /**
    * @description : Retorna fabricante 
    * @author Jefferson Martins | 12-29-2021 
    * @param fabricante 
    * @return List<Account> 
    **/
    private static List<Account> getFabricante(String fabricante) {
        return [SELECT Id FROM Account WHERE Name = :fabricante];
    }
                                
    /**
    * @description : Cria um carro com as informações passada na requisição
    * @author Jefferson Martins | 12-29-2021 
    * @param chassi 
    * @param combustivel 
    * @param renavam 
    * @param cor 
    * @param modelo 
    * @param fabricante 
    * @param placa 
    * @param situacaoVeiculo 
    * @param quilometragem 
    * @return List<Map<String, String>> 
    **/
    @HttpPost
    global static List<Map<String,String>> doPost(String chassi, String combustivel, 
                                String renavam, String cor, String modelo, 
                                String fabricante, String placa, String situacaoVeiculo, Decimal quilometragem) {
        
        Map<String,String> result = new Map<String,String>();
        try {
            
            Map<String,String> validacoes = validarCampos(chassi, combustivel, renavam, cor, modelo, 
                                                          placa, situacaoVeiculo, quilometragem);

            List<Account> fabricanteList = getFabricante(fabricante);

            if (fabricanteList.size() == 0) {
                validacoes.put('Fabricante', fabricante + ' não encontrado');
            }

            if (fabricanteList.size() > 1) {
                validacoes.put('Fabricante', fabricante + ' encontrado mais de uma vez.');
            }

            if (validacoes.size() > 0) {
                RestContext.response.statusCode = 400;
                return new List<Map<String,String>>{validacoes};
            }
            
            if (
                [SELECT Id, Name, Chassi__c, 
                        Combustivel__c, Renavam__c, Cor__c, 
                        Modelo__c, Fabricante__c, Placa__c,
                        SituacaoVeiculo__c, Quilometragem__c
                FROM Carro__c WHERE Placa__c = :placa OR 
                     Chassi__c = :chassi OR
                     Renavam__c = :renavam 
                LIMIT 1].size() > 0) {

                RestContext.response.statusCode = 422;
                result.put('Erro', 'Carro já existente com Placa, Renavam ou Chassi');
                return new List<Map<String, String>>{result}; 
            }
               
            Carro__c carro = new Carro__c();
            carro.Chassi__c = chassi;
            carro.Placa__c = placa;
            carro.Renavam__c = renavam;
            carro.Cor__c = cor;
            carro.Modelo__c = modelo;
            carro.SituacaoVeiculo__c = situacaoVeiculo;
            carro.Fabricante__c = fabricanteList[0].Id;
            carro.Quilometragem__c = quilometragem;
            carro.Combustivel__c = combustivel;

            insert carro;

            RestContext.response.statusCode = 201;
            RestContext.response.addHeader('Location', '/services/apexrest/Carro/' + placa);
            result.put('Resultado', 'Sucesso.');
        } catch (Exception e) {
            result.clear();
            result.put('Erro', e.getMessage());  
            RestContext.response.statusCode = 500;            
        }

        return new List<Map<String, String>>{result};    
        
    }


    /**
    * @description : Atualiza um carro com as informações passadas na requisição
    * @author Jefferson Martins | 12-29-2021 
    * @param chassi 
    * @param combustivel 
    * @param renavam 
    * @param cor 
    * @param modelo 
    * @param fabricante 
    * @param placa 
    * @param situacaoVeiculo 
    * @param quilometragem 
    * @return List<Map<String, String>> 
    **/
    @HttpPut
    global static List<Map<String,String>> doPut(String chassi, String combustivel, 
                                String renavam, String cor, String modelo, 
                                String fabricante, String placa, String situacaoVeiculo, Decimal quilometragem) {
        
        Map<String,String> result = new Map<String,String>();
        try {
            
            Map<String,String> validacoes = validarCampos(chassi, combustivel, renavam, cor, modelo, 
                                                          placa, situacaoVeiculo, quilometragem);

            List<Account> fabricanteList = getFabricante(fabricante);

            if (fabricanteList.size() == 0) {
                validacoes.put('Fabricante', fabricante + ' não encontrado');
            }

            if (fabricanteList.size() > 1) {
                validacoes.put('Fabricante', fabricante + ' encontrado mais de uma vez.');
            }

            if (validacoes.size() > 0) {
                RestContext.response.statusCode = 400;
                return new List<Map<String,String>>{validacoes};
            }

            Carro__c carro = [SELECT Id, Name, Chassi__c, 
                                     Combustivel__c, Renavam__c, Cor__c, 
                                     Modelo__c, Fabricante__c, Placa__c,
                                     SituacaoVeiculo__c, Quilometragem__c
                             FROM Carro__c WHERE Placa__c = :placa AND 
                                  Chassi__c = :chassi AND
                                  Renavam__c = :renavam 
                             LIMIT 1];
            
            if (carro == null) {
                RestContext.response.statusCode = 409;
                result.put('Erro', 'Carro não encontrado com Placa, Renavam e Chassi');
                return new List<Map<String, String>>{result}; 
            }
             
            carro.Chassi__c = chassi;
            carro.Placa__c = placa;
            carro.Renavam__c = renavam;
            carro.Cor__c = cor;
            carro.Modelo__c = modelo;
            carro.SituacaoVeiculo__c = situacaoVeiculo;
            carro.Fabricante__c = fabricanteList[0].Id;
            carro.Quilometragem__c = quilometragem;
            carro.Combustivel__c = combustivel;

            update carro;

            RestContext.response.statusCode = 200;
            RestContext.response.addHeader('Location', '/services/apexrest/Carro/' + placa);
            result.put('Resultado', 'Carro atualizado com sucesso.');
        } catch (Exception e) {
            result.clear();
            result.put('Erro', e.getMessage());  
            RestContext.response.statusCode = 500;            
        }

        return new List<Map<String, String>>{result};    
        
    }
}
