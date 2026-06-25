*** Settings ***
Library           Collections
Library           RequestsLibrary
Library           BuiltIn
Resource          ../../keywords/shipping_keywords.robot
Resource          ../../configs/config_api_malha.robot
Suite Setup       Criar Sessao API

*** Test Cases ***

Recalcular Cotacao Com Sucesso
    ${produto}=    Criar Produto    ${SKU}    2    ${PRICE}
    @{produtos}=    Create List    ${produto}

    ${body}=    Montar Body Cotacao Recalcular
    ...    ${ZIPCODE}
    ...    @{produtos}

    ${response}=    Recalcular Cotacao    ${body}

    Log    ${response.text}
    Should Be Equal As Integers    ${response.status_code}    201

Recalcular Cotacao Sem Produtos
    @{produtos}=    Create List

    ${body}=    Montar Body Cotacao Recalcular
    ...    ${ZIPCODE}
    ...    @{produtos}

    ${response}=    Recalcular Cotacao    ${body}

    Log    ${response.text}
    Should Be Equal As Integers    ${response.status_code}    422

Recalcular Cotacao CEP Invalido
    ${produto}=    Criar Produto    ${SKU}    1    ${PRICE}
    @{produtos}=   Create List    ${produto}

    ${body}=    Montar Body Cotacao Recalcular
    ...    00000000
    ...    @{produtos}

    ${response}=    Recalcular Cotacao    ${body}

    Log    ${response.text}
    Should Be Equal As Integers    ${response.status_code}    422


Recalcular Cotacao Sem Permissao
    ${produto}=    Criar Produto    ${SKU}    1    ${PRICE}
    @{produtos}=   Create List    ${produto}

    ${body}=    Montar Body Cotacao Recalcular
    ...    ${ZIPCODE}
    ...    @{produtos}
    ...    999
    ...    TEST
    ...    ${DISTRIBUTION_DOC}

    ${response}=    Recalcular Cotacao    ${body}

    ${json}=    Evaluate    ${response.json()}

    Log    ${json}

    Dictionary Should Contain Key    ${json}    error
    Should Be Equal    ${json['error']}    RECALC_SHIPPING_NOT_ALLOWED

Recalcular Cotacao DistribCenter Invalido
    ${produto}=    Criar Produto    ${SKU}    1    ${PRICE}
    @{produtos}=   Create List    ${produto}

    ${body}=    Montar Body Cotacao Recalcular
    ...    ${ZIPCODE}
    ...    @{produtos}
    ...    ${SURYA_CLUB_CODE}
    ...    ${SALES_ID}
    ...    00000000000000

    ${response}=    Recalcular Cotacao    ${body}

    Log    ${response.text}
    Should Be Equal As Integers    ${response.status_code}    422

Recalcular Cotacao Produtos Multiplo
    ${produto1}=    Criar Produto    ${SKU}    2    ${PRICE}
    ${produto2}=    Criar Produto    ${SKU}    3    ${PRICE}

    @{produtos}=    Create List    ${produto1}    ${produto2}

    ${body}=    Montar Body Cotacao Recalcular
    ...    ${ZIPCODE}
    ...    @{produtos}

    ${response}=    Recalcular Cotacao    ${body}

    Log    ${response.text}

    Should Be Equal As Integers    ${response.status_code}    201