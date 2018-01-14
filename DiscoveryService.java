package com.atn.tendy.discovery;

import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.os.Binder;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.preference.PreferenceManager;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.widget.RemoteViews;

import com.atn.tendy.Dtos;
import com.atn.tendy.MainActivity;
import com.atn.tendy.R;
import com.atn.tendy.utils.Logs;
import com.atn.tendy.utils.Utils;
import com.google.firebase.crash.FirebaseCrash;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.Random;

import ch.uepaa.p2pkit.P2PKit;
import ch.uepaa.p2pkit.P2PKitStatusListener;
import ch.uepaa.p2pkit.StatusResult;
import ch.uepaa.p2pkit.discovery.DiscoveryListener;
import ch.uepaa.p2pkit.discovery.DiscoveryPowerMode;
import ch.uepaa.p2pkit.discovery.Peer;

public class DiscoveryService extends Service {
    static long DISCOVERY_INTERVALS = 30 * 1000; //30 seconds between scans
    SharedPreferences prefs;
    IBinder mBinder = new ServiceBinder();

    public class ServiceBinder extends Binder {
        public DiscoveryService getService() {
            return DiscoveryService.this;
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        Logs.log("DiscoveryService", "onBind");
        p2pInfoPushBlock.run();
        return mBinder;
    }

    public DiscoveryService() {
    }

    @Override
    public void onCreate() {
        prefs = PreferenceManager.getDefaultSharedPreferences(this);
    }

    @Override
    public void onDestroy() {
        try {
           // P2PKit.removeDiscoveryListener(mDiscoveryListener);
           // P2PKit.stopDiscovery();
           // P2PKit.removeStatusListener(mStatusListener);
           // P2PKit.disable();
            p2pHandler.removeCallbacks(p2pInfoPushBlock);
        } catch (Exception e) {
            e.printStackTrace();
        }
        super.onDestroy();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Logs.log("DiscoveryService", "onStartCommand");
        try {
            P2PKit.enable(getApplicationContext(), getString(R.string.p2pkit_api_key), mStatusListener);
            final String profileJson = prefs.getString("profile", "");
            P2PKit.startDiscovery(new Dtos.Profile(profileJson).identifier.getBytes(), DiscoveryPowerMode.HIGH_PERFORMANCE, mDiscoveryListener);
        } catch (Exception e){e.printStackTrace();}
        p2pInfoPushBlock.run();
        return START_STICKY;
    }

    private final P2PKitStatusListener mStatusListener = new P2PKitStatusListener() {
        @Override
        public void onEnabled() {
            Logs.log("DiscoveryListener", "onEnabled " + new Random().nextInt());
        }

        @Override
        public void onDisabled() {
            Logs.log("DiscoveryListener", "onDisabled");
        }

        @Override
        public void onError(StatusResult statusResult) {
            Logs.log("DiscoveryListener", "onError");
        }

        @Override
        public void onException(Throwable throwable) {
            Logs.log("DiscoveryListener", "onException");
            if (P2PKit.isEnabled() == false) {
                try {
                    P2PKit.enable(getApplicationContext(), getString(R.string.p2pkit_api_key), mStatusListener);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    };

    private final DiscoveryListener mDiscoveryListener = new DiscoveryListener() {
        @Override
        public void onStateChanged(final int state) {
            Log.d("DiscoveryListener", "State changed: " + state);
        }

        @Override
        public void onPeerDiscovered(final Peer peer) {
            Log.d("DiscoveryListener", "Peer discovered: " + peer.getPeerId() + " with info: " + new String(peer.getDiscoveryInfo()));
            addProfileToProfilesList(new String(peer.getDiscoveryInfo()));
        }

        @Override
        public void onPeerLost(final Peer peer) {
            Log.d("DiscoveryListener", "Peer lost: " + peer.getPeerId());
        }

        @Override
        public void onPeerUpdatedDiscoveryInfo(Peer peer) {
            Log.d("DiscoveryListener", "Peer updated: " + peer.getPeerId() + " with new info: " + new String(peer.getDiscoveryInfo()));
            addProfileToProfilesList(new String(peer.getDiscoveryInfo()));
        }

        @Override
        public void onProximityStrengthChanged(Peer peer) {
            Log.d("DiscoveryListener", "Peer " + peer.getPeerId() + " changed proximity strength: " + peer.getProximityStrength());
            addProfileToProfilesList(new String(peer.getDiscoveryInfo()));
        }
    };


    boolean shouldSendNotification = false;

    synchronized private void addProfileToProfilesList(final String readMessage) {
        if (readMessage == null || readMessage.isEmpty()) return;
        Logs.log("addProfileToList", "in");
        try {
            final Dtos.Profile me = new Dtos.Profile(prefs.getString("profile", ""));
            final String chatId = Utils.getChatId(me.identifier, readMessage);
            FirebaseDatabase.getInstance().getReference("chats").child(chatId).addListenerForSingleValueEvent(new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot dataSnapshot) {
                    Logs.log("addProfileToList", "dataSnapshot");
                    if (dataSnapshot.getValue() == null) {
                        Logs.log("addProfileToList", "dataSnapshot ok");
                        FirebaseDatabase.getInstance().getReference("profiles").child(readMessage).addListenerForSingleValueEvent(new ValueEventListener() {
                            @Override
                            public void onDataChange(DataSnapshot dataSnapshot) {
                                Logs.log("addProfileToList", "dataSnapshot 2");
                                Dtos.Profile profile = dataSnapshot.getValue(Dtos.Profile.class);
                                if (profile == null || profile.username == null) return;
                                try {
                                    Logs.log("addProfileToList", "dataSnapshot 2 ok");
                                    shouldSendNotification = true;
                                    JSONArray arr = new JSONArray(prefs.getString("discoveryArray", "[]"));
                                    JSONObject o = new JSONObject(profile.toJsonString());
                                    o.put("dateAdded", System.currentTimeMillis());
                                    for (int i = 0; i < arr.length(); i++) {
                                        if (arr.getJSONObject(i).getString("identifier").equals(o.getString("identifier"))) {
                                            arr.remove(i);
                                            shouldSendNotification = false;
                                            break;
                                        }
                                    }
                                    arr.put(o);
                                    prefs.edit().putString("discoveryArray", arr.toString()).commit();
                                    if (shouldSendNotification)
                                        sendAroundYouNotification(arr);
                                    try {
                                        Intent intent = new Intent("discovery");
                                        LocalBroadcastManager.getInstance(DiscoveryService.this).sendBroadcast(intent);
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            }

                            @Override
                            public void onCancelled(DatabaseError databaseError) {

                            }
                        });
                    }
                }

                @Override
                public void onCancelled(DatabaseError databaseError) {

                }
            });
        } catch (Exception e) {
            e.printStackTrace();
            FirebaseCrash.log("got identifier: " + readMessage + " not in db");
        }
    }

    final static public int DISCOVERY_NOTIFICATION_ID = 1;

    synchronized private void sendAroundYouNotification(JSONArray arr) {
        if (arr.length() == 0) return;
        if (prefs.getBoolean("isAppActive", true)) return;
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        final PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT);
        final RemoteViews remoteViews = getRemoteViewsForDiscoveryNotification(arr);
        Utils.sendNotification(this, remoteViews, remoteViews, remoteViews, pendingIntent, DISCOVERY_NOTIFICATION_ID, true);
    }

    private RemoteViews getRemoteViewsForDiscoveryNotification(JSONArray arr) {
        RemoteViews remoteViews = new RemoteViews(getPackageName(),
                R.layout.discovery_notification);
        remoteViews.setTextViewText(R.id.title, String.format(getString(R.string.tendi_found_1_s_people_around_you), arr.length() + ""));
        for (int i = 0; i < arr.length() && i < 5; i++) {
            try {
                Dtos.Profile profile = new Dtos.Profile(arr.getJSONObject(i).toString());
                Bitmap bitmap = ImageLoader.getInstance().loadImageSync(profile.imageUrl, Utils.displayImageOptions);
                int resId = R.id.image0;
                if (i == 1) resId = R.id.image1;
                else if (i == 2) resId = R.id.image2;
                else if (i == 3) resId = R.id.image3;
                else if (i == 4) resId = R.id.image4;
                if (bitmap != null) {
                    remoteViews.setImageViewBitmap(resId, Utils.getCircleBitmap(bitmap));
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return remoteViews;
    }

    Handler p2pHandler = new Handler(Looper.getMainLooper());
    Runnable p2pInfoPushBlock = new Runnable() {
        @Override
        public void run() {
            try {
                final String profileJson = prefs.getString("profile", "");
                if (Dtos.Profile.isValidProfile(profileJson)) {
                    try {
                        P2PKit.stopDiscovery();
                        P2PKit.startDiscovery(new Dtos.Profile(profileJson).identifier.getBytes(), DiscoveryPowerMode.HIGH_PERFORMANCE, mDiscoveryListener);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                Logs.log("p2pInfoPushBlock", "discovery is on");
                if (this != null && p2pHandler != null)
                    p2pHandler.postDelayed(this, DISCOVERY_INTERVALS);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    };

}
