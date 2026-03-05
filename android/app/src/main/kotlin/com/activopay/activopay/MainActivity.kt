package com.activopay.activopay

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.suiche7b.sdk.qrcode.functions.nfc.NfcScanCodeQrSimple
import org.suiche7b.sdk.qrcode.functions.code.ParseQR

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.activopay.activopay/nfc_sdk"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startNfcPayment" -> {
                    val amount = call.argument<Double>("amount")
                    try {
                        // Ejemplo de uso de la SDK
                        val nfcScanner = NfcScanCodeQrSimple()
                        // Aquí iría la lógica real de inicio de escaneo NFC/Pago

                        val mockResult = mapOf(
                            "status" to "success",
                            "transactionId" to "NFC-${System.currentTimeMillis()}",
                            "amount" to amount
                        )
                        result.success(mockResult)
                    } catch (e: Exception) {
                        result.error("SDK_ERROR", e.message, null)
                    }
                }
                "scanQrCode" -> {
                    try {
                        // Ejemplo de uso de la SDK para QR
                        val qrParser = ParseQR()
                        result.success("MOCK_QR_DATA_VIA_SDK")
                    } catch (e: Exception) {
                        result.error("SDK_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
