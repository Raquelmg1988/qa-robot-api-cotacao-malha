*** Settings ***
Library           RequestsLibrary
Resource          ../../keywords/shipping_keywords.robot
Resource          ../../configs/config_api_malha.robot
Suite Setup       Criar Sessao API

*** Test Cases ***

Cotacao De Frete Com Sucesso
    ${produto}=    Criar Produto    ${SKU}    1    ${PRICE}
    @{produtos}=   Create List    ${produto}
    ${body}=       Montar Body Cotacao    ${ZIPCODE}    @{produtos}
    Log To Console    Body enviado: ${body}
    ${response}=   POST On Session    malha    /shipping-quote    json=${body}    expected_status=any
    Log To Console    Status: ${response.status_code} | Resposta: ${response.text}
    Should Be Equal As Integers    ${response.status_code}    201

Cotacao Sem Estoque
    ${produto}=    Criar Produto    ${SKU_SEM_ESTOQUE}    ${QTD_SEM_ESTOQUE}    ${PRICE_SEM_ESTOQUE}
    @{produtos}=   Create List    ${produto}
    ${body}=       Montar Body Cotacao    ${ZIPCODE}    @{produtos}
    ${response}=   POST On Session    malha    /shipping-quote    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201

Cotacao CEP Invalido
    ${produto}=    Criar Produto    ${SKU}    10    ${PRICE}
    @{produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=00000000
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    Set To Dictionary    ${body}    products=${produtos}
    ${response}=   POST On Session    malha    /shipping-quote    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    502

Cotacao Sem Produtos
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${ZIPCODE}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    products=${EMPTY}
    ${response}=   POST On Session    malha    /shipping-quote    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422