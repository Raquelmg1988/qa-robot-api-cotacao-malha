*** Settings ***
Library           Collections
Library           RequestsLibrary
Library           BuiltIn
Resource          ../configs/config_api_malha.robot


*** Keywords ***

Criar Sessao API
    Create Session
    ...    malha
    ...    ${BASE_URL}
    ...    headers=${HEADERS}
    ...    verify=False


Criar Produto
    [Arguments]    ${sku}    ${qtd}    ${price}

    ${qtd_num}=    Convert To Number    ${qtd}
    ${price_num}=  Convert To Number    ${price}

    ${produto}=    Create Dictionary
    ...    sku=${sku}
    ...    quantity=${qtd_num}
    ...    price=${price_num}

    RETURN    ${produto}


Montar Body Cotacao
    [Arguments]    ${zipcode}    @{produtos}

    ${body}=    Create Dictionary
    ...    deliveryZipCode=${zipcode}
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}

    RETURN    ${body}


Montar Body Cotacao Recalcular
    [Arguments]
    ...    ${zipcode}
    ...    @{produtos}
    ...    ${suryaClubCode}=${SURYA_CLUB_CODE}
    ...    ${salesPersonId}=${SALES_ID}
    ...    ${distributionDoc}=${DISTRIBUTION_DOC}

    ${body}=    Create Dictionary
    ...    deliveryZipCode=${zipcode}
    ...    products=${produtos}
    ...    suryaClubCode=${suryaClubCode}
    ...    salesPersonProtheusId=${salesPersonId}
    ...    distributionCenterDocument=${distributionDoc}

    RETURN    ${body}


Solicitar Cotacao
    [Arguments]    @{produtos}

    ${body}=    Montar Body Cotacao
    ...    ${ZIPCODE}
    ...    @{produtos}

    ${response}=    POST On Session
    ...    malha
    ...    ${ENDPOINT_SHIPPING_QUOTE}
    ...    json=${body}
    ...    expected_status=any

    RETURN    ${response}


Recalcular Cotacao
    [Arguments]    ${body}

    ${response}=    POST On Session
    ...    malha
    ...    ${ENDPOINT_RECALC}
    ...    json=${body}
    ...    expected_status=any

    RETURN    ${response}