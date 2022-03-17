
import 'package:dreamwallet/objects/envar.dart';

mixin Urls {
  String clientLoginUrl = '${EnVar.API_URL_HOME}/v1/client/login';
  String merchantLoginUrl = '${EnVar.API_URL_HOME}/v1/merchant/login';
  String cashierLoginUrl = '${EnVar.API_URL_HOME}/v1/cashier/login';
  String adminLoginUrl = '${EnVar.API_URL_HOME}/v1/admin/login/';

  String clientRegisterUrl = '${EnVar.API_URL_HOME}/v1/client/register';
  String clientCreateTransactionUrl = '${EnVar.API_URL_HOME}/v1/client/transaction';
  String clientGetTransactionsUrl = '${EnVar.API_URL_HOME}/v1/client/all-transaction';

  String merchantGetTransactionsUrl = '${EnVar.API_URL_HOME}/v1/merchant/all-transaction';
  String merchantGetWithdrawalsUrl = '${EnVar.API_URL_HOME}/v1/merchant/all-withdrawl';

  String cashierTopupUrl = '${EnVar.API_URL_HOME}/v1/cashier/topup';
  String cashierGetTopupsUrl = '${EnVar.API_URL_HOME}/v1/cashier/all-topup';
  String cashierGetClientsUrl = '${EnVar.API_URL_HOME}/v1/cashier/all-client';

  String adminGetAccountsUrl = '${EnVar.API_URL_HOME}/v1/admin/all-client';
  String adminVerifyClientUrl = '${EnVar.API_URL_HOME}/v1/admin/verify';
  String adminCreateCashierUrl = '${EnVar.API_URL_HOME}/v1/admin/create-cashier';
  String adminCreateMerchantUrl = '${EnVar.API_URL_HOME}/v1/admin/create-merchant';
  String adminGetTopupsUrl = '${EnVar.API_URL_HOME}/v1/admin/all-topup';
  String adminGetWithdrawalsUrl = '${EnVar.API_URL_HOME}/v1/admin/all-withdrawl';
  String adminGetTransactionsUrl = '${EnVar.API_URL_HOME}/v1/admin/all-transaction';
  String adminGetMerchantsUrl = '${EnVar.API_URL_HOME}/v1/admin/merchant';
  String adminVerifyTopupsUrl = '${EnVar.API_URL_HOME}/v1/admin/update-topup';
  String adminTopupUrl = '${EnVar.API_URL_HOME}/v1/admin/topup';
  String adminCreateWithdrawalUrl = '${EnVar.API_URL_HOME}/v1/admin/withdrawl';
}