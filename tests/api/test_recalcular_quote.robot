*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           BuiltIn
Resource          ../../keywords/shipping_keywords.robot
Resource          ../../configs/config_api_malha.robot
Suite Setup       Criar Sessao API

*** Variables ***
${VALID_ZIPCODE}           01310100
${INVALID_ZIPCODE}         00000000
${SKU_VALID}               PROD-001
${SKU_INVALID}             PROD-999
${SURYA_CLUB_CODE}         10
${SALES_ID}                PROT-SELLER-123
${DISTRIBUTION_DOC}        12345678000195
${PRICE}                   75.50
${QTY}                     2

*** Test Cases ***

Recalculo De Frete Com Sucesso
    ${produto}=    Criar Produto    ${SKU_VALID}    ${QTY}    ${PRICE}
    @{produtos}=   Create List    ${produto}
    ${body}=       Montar Body Cotacao Recalcular    ${VALID_ZIPCODE}    @{produtos}    ${SURYA_CLUB_CODE}    ${SALES_ID}    ${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201

Recalculo Sem Produtos
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${VALID_ZIPCODE}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    distributionCenterDocument=${DISTRIBUTION_DOC}
    ...    products=${EMPTY}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422

Recalculo CEP Invalido
    ${produto}=    Criar Produto    ${SKU_VALID}    ${QTY}    ${PRICE}
    @{produtos}=   Create List    ${produto}
    ${body}=       Montar Body Cotacao Recalcular    ${INVALID_ZIPCODE}    @{produtos}    ${SURYA_CLUB_CODE}    ${SALES_ID}    ${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422

Recalculo Produto Quantidade Zero
    ${produto}=    Criar Produto    ${SKU_VALID}    0    ${PRICE}
    @{produtos}=   Create List    ${produto}
    ${body}=       Montar Body Cotacao Recalcular    ${VALID_ZIPCODE}    @{produtos}    ${SURYA_CLUB_CODE}    ${SALES_ID}    ${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422

Recalculo Produto Preco Negativo
    ${produto}=    Criar Produto    ${SKU_VALID}    ${QTY}    -10
    @{produtos}=   Create List    ${produto}
    ${body}=       Montar Body Cotacao Recalcular    ${VALID_ZIPCODE}    @{produtos}    ${SURYA_CLUB_CODE}    ${SALES_ID}    ${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422

Recalculo Distribuicao Invalida
    ${produto}=    Criar Produto    ${SKU_VALID}    ${QTY}    ${PRICE}
    @{produtos}=   Create List    ${produto}
    ${body}=       Montar Body Cotacao Recalcular    ${VALID_ZIPCODE}    @{produtos}    ${SURYA_CLUB_CODE}    ${SALES_ID}    00000000000000
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422

Recalculo Produto Inexistente
    ${produto}=    Criar Produto    ${SKU_INVALID}    ${QTY}    ${PRICE}
    @{produtos}=   Create List    ${produto}
    ${body}=       Montar Body Cotacao Recalcular    ${VALID_ZIPCODE}    @{produtos}    ${SURYA_CLUB_CODE}    ${SALES_ID}    ${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422

Recalculo Todos Tipos de Carrier
    ${produto}=    Criar Produto    ${SKU_VALID}    ${QTY}    ${PRICE}
    @{produtos}=   Create List    ${produto}
    ${body}=       Montar Body Cotacao Recalcular    ${VALID_ZIPCODE}    @{produtos}    ${SURYA_CLUB_CODE}    ${SALES_ID}    ${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    ${json}=       Set Variable    ${response.json()}
    ${data}=       Get From Dictionary    ${json}    data
    ${express}=    Get From Dictionary    ${data[0]}    EXPRESS
    Dictionary Should Contain Key    ${express}    carrier
    Dictionary Should Contain Key    ${express}    value
    Dictionary Should Contain Key    ${express}    days
    ${standard}=   Get From Dictionary    ${data[0]}    STANDARD
    Dictionary Should Contain Key    ${standard}    carrier
    Dictionary Should Contain Key    ${standard}    value
    Dictionary Should Contain Key    ${standard}    days
    ${others}=     Get From Dictionary    ${data[0]}    OTHERS
    Length Should Be    ${others}    1
    Dictionary Should Contain Key    ${others[0]}    carrier
    Dictionary Should Contain Key    ${others[0]}    value
    Dictionary Should Contain Key    ${others[0]}    days

Recalculo Sem SuryaClubCode
    ${produto}=    Criar Produto    ${SKU_VALID}    ${QTY}    ${PRICE}
    @{produtos}=   Create List    ${produto}
    ${body}=       Montar Body Cotacao Recalcular    ${VALID_ZIPCODE}    @{produtos}    ${EMPTY}    ${SALES_ID}    ${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422

Recalculo Sem SalesPersonProtheusId
    ${produto}=    Criar Produto    ${SKU_VALID}    ${QTY}    ${PRICE}
    @{produtos}=   Create List    ${produto}
    ${body}=       Montar Body Cotacao Recalcular    ${VALID_ZIPCODE}    @{produtos}    ${SURYA_CLUB_CODE}    ${EMPTY}    ${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422
