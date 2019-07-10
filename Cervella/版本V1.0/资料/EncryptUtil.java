package hujianghao.posmvp.util;

import android.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;


/***
 * @author liumin13
 * @Description: 传输过程中敏感信息加密处理
 * @date 2017年5月17日
 */
public class EncryptUtil {

    private static String key = "1234567890000000";

    private static String ivStr = "1234567890000000";

    /**
     * @param src
     * @return
     * @Description:加密
     * @author liumin13
     */
    public static String encrypt(String src) {
        byte[] raw = key.getBytes();
        SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
        byte[] encrypted = null;
        try {
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");// "算法/模式/补码方式"0102030405060708
            IvParameterSpec iv = new IvParameterSpec(ivStr.getBytes());// 使用CBC模式，需要一个向量iv，可增加加密算法的强度
            cipher.init(Cipher.ENCRYPT_MODE, skeySpec, iv);
            encrypted = cipher.doFinal(src.getBytes());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return Base64.encodeToString(encrypted, Base64.NO_WRAP);
    }

    /**
     * @param src
     * @return
     * @Description: 解密
     * @author liumin13
     */
    public static String decrypt(String src) {
        try {
            byte[] raw = key.getBytes("ASCII");
            SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            IvParameterSpec iv = new IvParameterSpec(ivStr.getBytes());
            cipher.init(Cipher.DECRYPT_MODE, skeySpec, iv);
            byte[] encrypted1 = Base64.decode(src, Base64.DEFAULT);// 先用base64解密
            byte[] original = cipher.doFinal(encrypted1);
            return new String(original, "UTF-8");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

}
