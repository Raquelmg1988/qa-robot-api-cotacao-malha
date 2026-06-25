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
