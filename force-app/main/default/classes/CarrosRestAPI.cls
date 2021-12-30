/**
 * @description       : 
 * @author            : Jefferson Martins
 * @group             : 
 * @last modified on  : 12-30-2021
 * @last modified by  : Jefferson Martins
**/
@RestResource(urlMapping='/Carros/*')
global with sharing class CarrosRestAPI {
    private static Map<String,Account> fabricantes;

    /**
    * @description : Retorna retorna carro de acordo com a placa informada
    * @author Jefferson Martins | 12-29-2021 
    * @return Carro__c 
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
    * @description : Valida os campos da lista de objetos que vieream
    *                na requisição.
    * @author Jefferson Martins | 12-30-2021 
    * @param carros 
    * @return Map<String, String> 
    **/
    private static Map<String,String> validarCampos(List<CarroJSON> carros) {
        
        Map<String,String> validacoes = new Map<String,String>();
        
        for (CarroJSON carro : carros) {                
            if (carro.placa.length() != Carro__c.Placa__c.getDescribe().getLength()) {
                validacoes.put('Placa', String.format('Placa {0} inválida, deve estar no formato AAA1234', new List<String>{carro.placa}));            
            }
            if (carro.chassi.length() != Carro__c.Chassi__c.getDescribe().getLength()) {
                validacoes.put('Chassi', String.format('{0} Tamanho inválido, deve ter {1} caracteres.', new List<Object>{carro.chassi, Carro__c.Chassi__c.getDescribe().getLength()}));
            }
            if (carro.renavam.length() != Carro__c.Renavam__c.getDescribe().getLength()) {
                validacoes.put('Renavam', String.format('{0} inválido, deve ter {1} caracteres.', new List<Object>{carro.renavam, Carro__c.Renavam__c.getDescribe().getLength()}));
            }
            if (carro.combustivel.length() > Carro__c.Combustivel__c.getDescribe().getLength()) {
                validacoes.put('Combustível', 'Tamanho inválido, deve ter no máximo ' + Carro__c.Combustivel__c.getDescribe().getLength() + ' caracteres.');
            }
            if (carro.cor.length() > Carro__c.Cor__c.getDescribe().getLength()) {
                validacoes.put('Cor', 'Tamanho inválido, deve ter no máximo ' + Carro__c.Cor__c.getDescribe().getLength() + ' caracteres.');
            }
            if (carro.modelo.length() > Carro__c.Modelo__c.getDescribe().getLength()) {
                validacoes.put('Modelo', 'Tamanho inválido, deve ter no máximo ' + Carro__c.Modelo__c.getDescribe().getLength() + ' caracteres.');
            }
            if (carro.situacaoVeiculo.length() > Carro__c.SituacaoVeiculo__c.getDescribe().getLength()) {
                validacoes.put('Situação Veículo', 'Tamanho inválido, deve ter no máximo ' + Carro__c.SituacaoVeiculo__c.getDescribe().getLength() + ' caracteres.');
            }

            if (validacoes.size() > 0) 
                break;
        }

        return validacoes;
    }

    /**
    * @description : Valida os fabricantes informados na lista de objetos da requisição.
    * @author Jefferson Martins | 12-30-2021 
    * @param carros 
    * @return Map<String, String> 
    **/
    private static Map<String, String> validarFabricantes(List<CarroJSON> carros) {
        // Variavel onde ficara armazenado os Fabricantes(Accounts) para
        // serem utilizados no momento da criação/atualização dos carros
        fabricantes = new Map<String,Account>();
        Map<String, String> result = new Map<String,String>();

        // Prepara lista de fabricantes para realizar busca
        List<String> fabricantesStrList = new List<String>();
        for (CarroJSON carro : carros) 
            fabricantesStrList.add(carro.fabricante);

        // SOQL para buscar fabricantes de acordo com fabricantes informados
        // na requisição
        List<Account> fabricantesObjList = [SELECT Id, Name 
                                           FROM Account 
                                           WHERE Name IN :fabricantesStrList];

        if (fabricantesObjList.size() == 0) {
            result.put('Fabricante', 'Nenhum fabricante informado foi encontrado.');
            return result;
        }
        
        // Prepara o Map de Placa|Fabricante para utilizar no POST e PUT
        for (CarroJSON carro : carros) {
            for (Account fabricante : fabricantesObjList) {
                if (fabricante.Name == carro.fabricante) {
                    fabricantes.put(carro.placa, fabricante);
                }
            }
        }

        if (carros.size() != fabricantes.size()) {
            result.put('Fabricante', 'Um ou mais fabricantes não foram encontrados.');
        }

        return result;

    }

    
    /**
    * @description : Cria uma lista de carros passada na requisição
    * @author Jefferson Martins | 12-30-2021 
    * @param carros 
    * @return List<Map<String, String>> 
    **/
    @HttpPost
    global static List<Map<String,String>> doPost(List<CarroJSON> carros) {
        
        Map<String,String> result = new Map<String,String>();
        try {
            List<Carro__C> carrosList = new List<Carro__c>();

            // Validar campo dos objetos
            Map<String,String> validacoes = validarCampos(carros);                
            if (validacoes.size() > 0) {
                RestContext.response.statusCode = 400;
                return new List<Map<String,String>>{validacoes};
            }    

            // Validar fabricantes e armazenar map de placa|fabricante para
            // utilização mais abaixo
            Map<String,String> fabricanteValidacoes = validarFabricantes(carros);
            if (fabricanteValidacoes.size() > 0) {
                RestContext.response.statusCode = 400;
                return new List<Map<String,String>>{fabricanteValidacoes};
            }    

            for (CarroJSON carroJSON : carros) {
                Carro__c carro = new Carro__c();
                carro.Chassi__c = carroJSON.chassi;
                carro.Placa__c = carroJSON.placa;
                carro.Renavam__c = carroJSON.renavam;
                carro.Cor__c = carroJSON.cor;
                carro.Modelo__c = carroJSON.modelo;
                carro.SituacaoVeiculo__c = carroJSON.situacaoVeiculo;
                carro.Fabricante__c = fabricantes.get(carroJSON.placa).Id;
                carro.Quilometragem__c = carroJSON.quilometragem;
                carro.Combustivel__c = carroJSON.combustivel;

                carrosList.add(carro);
                
            }

            if (carrosList.size() == 0) {

            RestContext.response.statusCode = 400;
            result.put('xxx', 'xx.');
            }

            insert carrosList;

            RestContext.response.statusCode = 201;
            result.put('Resultado', 'Sucesso.');
        } catch (Exception e) {
            result.clear();
            result.put('Erro', e.getMessage());  
            RestContext.response.statusCode = 500;            
        }

        return new List<Map<String, String>>{result};    
        
    }

    /**
    * @description : Atualiza lista de carros passada na requisição
    * @author Jefferson Martins | 12-30-2021 
    * @param carros 
    * @return List<Map<String, String>> 
    **/
    @HttpPut
    global static List<Map<String,String>> doPut(List<CarroJSON> carros) {

        Map<String,String> result = new Map<String,String>();
    
        List<Carro__c> carrosUpdateList = new List<Carro__c>();
        try {
            // Validar campo dos objetos
            Map<String,String> validacoes = validarCampos(carros);                
            if (validacoes.size() > 0) {
                RestContext.response.statusCode = 400;
                return new List<Map<String,String>>{validacoes};
            }    

            // Validar fabricantes e armazenar map de placa|fabricante para
            // utilização mais abaixo
            Map<String,String> fabricanteValidacoes = validarFabricantes(carros);
            if (fabricanteValidacoes.size() > 0) {
                RestContext.response.statusCode = 400;
                return new List<Map<String,String>>{fabricanteValidacoes};
            }    

            // Prepara lista de placas para buscar carros para serem atualizados
            List<String> placasList = new List<String>()
;           for (CarroJSON carro : carros) {
                placasList.add(carro.placa);
            }
               
            // SOQL com a lista de carros 
            List<Carro__C> carrosList = 
                [SELECT Id, Name, Chassi__c, 
                        Combustivel__c, Renavam__c, Cor__c, 
                        Modelo__c, Fabricante__c, Placa__c,
                        SituacaoVeiculo__c, Quilometragem__c
                FROM Carro__c 
                WHERE     
                    Placa__c IN :placasList];

            
            // Percorrer lista recebida na requisição e processar atualização
            for (CarroJSON carroJSON : carros) {
                for (Carro__c carro : carrosList) {
                    if (carro.Placa__c == carroJSON.placa) {
                        carro.Chassi__c = carroJSON.chassi;
                        carro.Placa__c = carroJSON.placa;
                        carro.Renavam__c = carroJSON.renavam;
                        carro.Cor__c = carroJSON.cor;
                        carro.Modelo__c = carroJSON.modelo;
                        carro.SituacaoVeiculo__c = carroJSON.situacaoVeiculo;
                        carro.Fabricante__c = fabricantes.get(carroJSON.placa).Id;
                        carro.Quilometragem__c = carroJSON.quilometragem;
                        carro.Combustivel__c = carroJSON.combustivel;
                        carrosUpdateList.add(carro);
                    }                    
                }
                
            }

            if (carrosUpdateList.size() > 0)
                update carrosUpdateList;

            RestContext.response.statusCode = 201;
            result.put('Resultado', 'Sucesso.');
        } catch (Exception e) {
            result.clear();
            result.put('Erro', e.getMessage());  
            RestContext.response.statusCode = 500;            
        }

        return new List<Map<String, String>>{result};    
                                               
    }

    // Classe wrapper para fazer o parse do JSON do body da requisição
    global class CarroJSON {
        global String chassi;
        global String combustivel; 
        global String renavam;
        global String cor;
        global String modelo;
        global String fabricante;
        global String placa;
        global String situacaoVeiculo;
        global Decimal quilometragem;
    }

}
