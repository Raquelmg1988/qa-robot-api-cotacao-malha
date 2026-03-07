*** Settings ***
Library           Collections
Library           RequestsLibrary
Library           BuiltIn
Resource          ../configs/config_api_malha.robot

*** Keywords ***
Criar Sessao API
    Create Session    malha    ${BASE_URL}    headers=${HEADERS}

*** Keywords ***
Criar Produto
    [Arguments]    ${sku}    ${qtd}    ${price}
    ${qtd_num}=    Convert To Number    ${qtd}
    ${price_num}=  Convert To Number    ${price}
    ${produto}=    Create Dictionary    sku=${sku}    quantity=${qtd_num}    price=${price_num}
    RETURN         ${produto}

Montar Body Cotacao
    [Arguments]    ${zipcode}    @{produtos}
    ${body}=    Create Dictionary
    ...    deliveryZipCode=${zipcode}
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    RETURN    ${body}

Solicitar Cotacao
    [Arguments]    @{produtos}
    ${body}=    Montar Body Cotacao    ${ZIPCODE}    @{produtos}
    ${response}=    POST On Session    malha    /shipping-quote    json=${body}    expected_status=any
    RETURN    ${response}