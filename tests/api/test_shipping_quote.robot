*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           BuiltIn
Resource          ../../keywords/shipping_keywords.robot
Resource          ../../configs/config_api_malha.robot
Suite Setup       Criar Sessao API

*** Test Cases ***
Cotacao Multiplos Produtos
    ${produto1}=    Criar Produto    ${SKU}    5    ${PRICE}
    ${produto2}=    Criar Produto    ${SKU}    3    ${PRICE}
    @{produtos}=    Create List    ${produto1}    ${produto2}
    ${payload}=    Create Dictionary
    ...    deliveryZipCode=${ZIPCODE}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    Set To Dictionary    ${payload}    products=${produtos}
    ${response}=   POST On Session    malha    /shipping-quote    json=${payload}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201

Validar Estrutura Carrier
    ${produto}=    Criar Produto    ${SKU}    5    ${PRICE}
    ${response}=   Solicitar Cotacao    ${produto}
    Should Be Equal As Integers    ${response.status_code}    201
    ${json}=       Set Variable    ${response.json()}
    ${data}=       Get From Dictionary    ${json}    data
    ${express}=    Get From Dictionary    ${data}    EXPRESS
    Dictionary Should Contain Key    ${express}    carrier
    Dictionary Should Contain Key    ${express}    value
    Dictionary Should Contain Key    ${express}    days

Cotacao De Frete Com Sucesso (Shipping)
    ${produto}=    Criar Produto    ${SKU}    1    ${PRICE}
    @{produtos}=   Create List    ${produto}
    ${payload}=    Montar Body Cotacao    ${ZIPCODE}    @{produtos}
    ${response}=   POST On Session    malha    /shipping-quote    json=${payload}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201

Cotacao Sem Estoque (Shipping)
    ${produto}=    Criar Produto    ${SKU_SEM_ESTOQUE}    ${QTD_SEM_ESTOQUE}    ${PRICE_SEM_ESTOQUE}
    @{produtos}=   Create List    ${produto}
    ${payload}=    Montar Body Cotacao    ${ZIPCODE}    @{produtos}
    ${response}=   POST On Session    malha    /shipping-quote    json=${payload}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201

Cotacao CEP Invalido (Shipping)
    ${produto}=    Criar Produto    ${SKU}    10    ${PRICE}
    @{produtos}=   Create List    ${produto}
    ${payload}=    Create Dictionary
    ...    deliveryZipCode=00000000
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    Set To Dictionary    ${payload}    products=${produtos}
    ${response}=   POST On Session    malha    /shipping-quote    json=${payload}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    502

Cotacao Sem Produtos (Shipping)
    ${payload}=    Create Dictionary
    ...    deliveryZipCode=${ZIPCODE}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    products=${EMPTY}
    ${response}=   POST On Session    malha    /shipping-quote    json=${payload}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422
