*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           BuiltIn
Resource          ../../keywords/shipping_keywords.robot
Resource          ../../configs/config_api_malha.robot
Suite Setup       Criar Sessao API

*** Variables ***
${VALID_ZIPCODE}           85340000
${INVALID_ZIPCODE}         00000000
${SKU_VALID}               100306000
${SKU_INVALID}             PROD-999
${SURYA_CLUB_CODE}         20
${SALES_ID}                A00018
${DISTRIBUTION_DOC}        00814559000155
${PRICE}                   11.86
${QTY}                     2

*** Test Cases ***

Recalculo De Frete Com Sucesso
    ${produto}=    Criar Produto    ${SKU_VALID}    ${QTY}    ${PRICE}
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${VALID_ZIPCODE}
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    distributionCenterDocument=${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Log To Console    Status Recalculo: ${response.status_code} | Resposta: ${response.text}
    Should Be Equal As Integers    ${response.status_code}    201
    
    # BLINDAGEM: Garante que o corpo não veio vazio e possui a estrutura básica
    ${json}=       Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json}    data

Recalculo Sem Produtos
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${VALID_ZIPCODE}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    distributionCenterDocument=${DISTRIBUTION_DOC}
    ...    products=${EMPTY}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422
    
    # BLINDAGEM: Valida o contrato de erro detalhado do Swagger
    ${json}=       Set Variable    ${response.json()}
    Dictionary Should Contain Item    ${json}    code        VALIDATION

Recalculo CEP Invalido
    ${produto}=    Criar Produto    ${SKU_VALID}    ${QTY}    ${PRICE}
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${INVALID_ZIPCODE}
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    distributionCenterDocument=${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    # Exige 422 da documentação (Vai acusar FAIL por causa do bug 502 da API)
    Should Be Equal As Integers    ${response.status_code}    422

Recalculo Produto Quantidade Zero
    ${produto}=    Criar Produto    ${SKU_VALID}    0    ${PRICE}
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${VALID_ZIPCODE}
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    distributionCenterDocument=${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    # Exige 422 da documentação (Vai acusar FAIL por causa do bug 201 da API)
    Should Be Equal As Integers    ${response.status_code}    422

Recalculo Produto Preco Negativo
    ${produto}=    Criar Produto    ${SKU_VALID}    ${QTY}    -10
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${VALID_ZIPCODE}
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    distributionCenterDocument=${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422

Recalculo Distribuicao Invalida
    ${produto}=    Criar Produto    ${SKU_VALID}    ${QTY}    ${PRICE}
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${VALID_ZIPCODE}
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    distributionCenterDocument=00000000000000
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    # Exige 422 da documentação (Vai acusar FAIL por causa do bug 500 da API)
    Should Be Equal As Integers    ${response.status_code}    422

Recalculo Produto Inexistente
    ${produto}=    Criar Produto    ${SKU_INVALID}    ${QTY}    ${PRICE}
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${VALID_ZIPCODE}
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    distributionCenterDocument=${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    # Exige 422 da documentação (Vai acusar FAIL por causa do bug 502 da API)
    Should Be Equal As Integers    ${response.status_code}    422

Recalculo Todos Tipos de Carrier
    ${produto}=    Criar Produto    ${SKU_VALID}    ${QTY}    ${PRICE}
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${VALID_ZIPCODE}
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    distributionCenterDocument=${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    201
    ${json}=       Set Variable    ${response.json()}
    ${data}=       Get From Dictionary    ${json}    data
    
    # AJUSTADO: Valida EXPRESS
    ${express}=    Get From Dictionary    ${data}    EXPRESS
    Dictionary Should Contain Key    ${express}    carrier
    Dictionary Should Contain Key    ${express}    value
    Dictionary Should Contain Key    ${express}    days
    
    # AJUSTADO: Valida se a chave OTHERS existe no objeto de dados
    Dictionary Should Contain Key    ${data}    OTHERS
    
    # ALERTA DE CONTRATO: Valida se STANDARD existe conforme a documentação
    # (Vai falhar aqui apontando o Bug de Contrato para os DEVs corrigirem)
    Dictionary Should Contain Key    ${data}    STANDARD

Recalculo Sem SuryaClubCode
    ${produto}=    Criar Produto    ${SKU_VALID}    ${QTY}    ${PRICE}
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${VALID_ZIPCODE}
    ...    products=${produtos}
    ...    suryaClubCode=${EMPTY}
    ...    salesPersonProtheusId=${SALES_ID}
    ...    distributionCenterDocument=${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    422

Recalculo Sem SalesPersonProtheusId
    ${produto}=    Criar Produto    ${SKU_VALID}    ${QTY}    ${PRICE}
    ${produtos}=   Create List    ${produto}
    ${body}=       Create Dictionary
    ...    deliveryZipCode=${VALID_ZIPCODE}
    ...    products=${produtos}
    ...    suryaClubCode=${SURYA_CLUB_CODE}
    ...    salesPersonProtheusId=${EMPTY}
    ...    distributionCenterDocument=${DISTRIBUTION_DOC}
    ${response}=   POST On Session    malha    /shipping-quote/recalc    json=${body}    expected_status=any
    # Exige 422 da documentação (Vai acusar FAIL por causa do bug 201 da API)
    Should Be Equal As Integers    ${response.status_code}    422
