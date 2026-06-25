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
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${ZIPCODE}
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    distributionCenterDocument=${DISTRIBUTION_DOC}

    ${response}=    POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Log    ${response.text}
    Should Be Equal As Integers    ${response.status_code}    201

Recalcular Cotacao Sem Produtos
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${ZIPCODE}
    ...    products=${EMPTY}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    distributionCenterDocument=${DISTRIBUTION_DOC}

    ${response}=    POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Log    ${response.text}
    Should Be Equal As Integers    ${response.status_code}    422

Recalcular Cotacao CEP Invalido
    ${produto}=    Criar Produto    ${SKU}    1    ${PRICE}
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=00000000
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    distributionCenterDocument=${DISTRIBUTION_DOC}

    ${response}=    POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Log    ${response.text}
    Should Be Equal As Integers    ${response.status_code}    422
    
    ${json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Item    ${json}    code        VALIDATION

Recalcular Cotacao Sem Permissao
    ${produto}=    Criar Produto    ${SKU}    1    ${PRICE}
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${ZIPCODE}
    ...    products=${produtos}
    ...    suryaClubCode=999
    ...    salesPersonProtheusId=TEST
    ...    distributionCenterDocument=${DISTRIBUTION_DOC}

    ${response}=    POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422
    
    ${json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Item    ${json}    code        VALIDATION

Recalcular Cotacao DistribCenter Invalido
    ${produto}=    Criar Produto    ${SKU}    1    ${PRICE}
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${ZIPCODE}
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    distributionCenterDocument=00000000000000

    ${response}=    POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Log    ${response.text}
    Should Be Equal As Integers    ${response.status_code}    422

Recalcular Cotacao Produtos Multiplo
    ${produto1}=    Criar Produto    ${SKU}    2    ${PRICE}
    ${produto2}=    Criar Produto    ${SKU}    3    ${PRICE}
    ${produtos}=    Create List    ${produto1}    ${produto2}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${ZIPCODE}
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    distributionCenterDocument=${DISTRIBUTION_DOC}

    ${response}=    POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Log    ${response.text}
    Should Be Equal As Integers    ${response.status_code}    201
