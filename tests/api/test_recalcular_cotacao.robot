*** Settings ***
Library           Collections
Library           RequestsLibrary
Library           BuiltIn
Resource          ../../keywords/shipping_keywords.robot
Resource          ../../configs/config_api_malha.robot
Suite Setup       Criar Sessao API

*** Test Cases ***
Recalcular Cotacao Com Sucesso
    ${produto}=    Criar Produto    PROD-001    2    75.5
    @{produtos}=    Create List    ${produto}
    ${body}=    Montar Body Cotacao Recalcular    01310100    @{produtos}    10    PROT-SELLER-123    12345678000195
    ${response}=    POST On Session    malha    /cota%C3%A7%C3%A3o-de-envio/recalcular    json=${body}    expected_status=any

Recalcular Cotacao Sem Produtos
    ${body}=       Montar Body Cotacao Recalcular    ${ZIPCODE}    ${EMPTY}    ${SURYA_CLUB_CODE}    ${SALES_ID}    ${DISTRIBUTION_DOC}
    ${response}=    POST On Session    malha    /cota%C3%A7%C3%A3o-de-envio/recalcular    json=${body}    expected_status=any    

Recalcular Cotacao CEP Invalido
    ${produto}=    Criar Produto    ${SKU}    1    ${PRICE}
    @{produtos}=   Create List    ${produto}
    ${body}=       Montar Body Cotacao Recalcular    00000000    @{produtos}    ${SURYA_CLUB_CODE}    ${SALES_ID}    ${DISTRIBUTION_DOC}
    ${response}=    POST On Session    malha    /cota%C3%A7%C3%A3o-de-envio/recalcular    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422

Recalcular Cotacao Sem Permissao
    ${produto}=    Criar Produto    ${SKU}    1    ${PRICE}
    @{produtos}=   Create List    ${produto}
    ${body}=       Montar Body Cotacao Recalcular    ${ZIPCODE}    @{produtos}
    ${response}=    POST On Session    malha    /cota%C3%A7%C3%A3o-de-envio/recalcular    json=${body}    expected_status=any
    # Aqui você pode validar se o código de erro da API é "RECALC_SHIPPING_NOT_ALLOWED"
    ${json}=       Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${response.json()}    data
    Should Be Equal    ${json['code']}    RECALC_SHIPPING_NOT_ALLOWED

Recalcular Cotacao DistribCenter Invalido
    ${produto}=    Criar Produto    ${SKU}    1    ${PRICE}
    @{produtos}=   Create List    ${produto}
    ${body}=       Montar Body Cotacao Recalcular    ${ZIPCODE}    @{produtos}    ${SURYA_CLUB_CODE}    ${SALES_ID}    00000000000000
    ${response}=    POST On Session    malha    /cota%C3%A7%C3%A3o-de-envio/recalcular    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422

Recalcular Cotacao Produtos Multiplo
    ${produto1}=    Criar Produto    ${SKU}    2    ${PRICE}
    ${produto2}=    Criar Produto    ${SKU2}    3    ${PRICE2}
    @{produtos}=    Create List    ${produto1}    ${produto2}
    ${body}=       Montar Body Cotacao Recalcular    ${ZIPCODE}    @{produtos}    ${SURYA_CLUB_CODE}    ${SALES_ID}    ${DISTRIBUTION_DOC}
    ${response}=    POST On Session    malha    /cota%C3%A7%C3%A3o-de-envio/recalcular    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201