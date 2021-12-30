# salesforce-apex-rest-api



# Install using Scratch Org

1 - Authorize your hub and provide it with a alias(DevHub in the following command):

    sfdx force:auth:web:login -d -a DevHub

2 - Clone repository

    git clone git clone https://github.com/jeffersonmartins/salesforce-apex-rest-api.git

3 - Navigate to the directory of the repository you just cloned.

    cd salesforce-apex-rest-api

4 - Create a scratch org and provide it with an alias (salesforce-apex-rest-api in the command bellow)

    sfdx force:org:create -s -f config/project-scratch-def.json -a salesforce-apex-rest-api

5 - Push the source to your scratch org

    sfdx force:source:push -u salesforce-apex-rest-api

6 - Open the sandbox org

    sfdx force:org:open -u salesforce-apex-rest-api

7 - Open https://workbench.developerforce.com/restExplorer.php and POST or PUT
     
   Atualizar ou criar um único carro

     /services/apexrest/Carro/
    
    {
      "chassi": "11111111111111111",
      "combustivel": "FLEX",
      "renavam": "11111111111",
      "cor": "AZUL",
      "modelo": "FUSCA",
      "fabricante": "Volkswagen",
      "placa": "AAA1234",
      "situacaoVeiculo": "Ótimo Estado",
      "quilometragem": 150.00
    }

Criar ou atualizar uma lista de carros

    /services/apexrest/Carros/
    
    {"carros" : [
        {
            "chassi": "11111111111111111",
            "combustivel": "GASOLINA",
            "renavam": "11111111111",
            "cor": "AZUL",
            "modelo": "FUSCA",
            "fabricante": "Volkswagen",
            "placa": "AAA1234",
            "situacaoVeiculo": "Ótimo Estado",
            "quilometragem": 150.00
        },
        {
            "chassi": "222222222222222",
            "combustivel": "FLEX",
            "renavam": "22222222222",
            "cor": "AMARELA",
            "modelo": "BRASILIA",
            "fabricante": "Volkswagen",
            "placa": "BBB1234",
            "situacaoVeiculo": "De portas abertas",
            "quilometragem": 200.00
        }]
    }
