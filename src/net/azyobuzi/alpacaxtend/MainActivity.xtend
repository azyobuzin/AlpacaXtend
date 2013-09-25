package net.azyobuzi.alpacaxtend

import android.support.v4.app.FragmentActivity
import android.os.Bundle
import android.view.Window
import android.support.v4.content.AsyncTaskLoader
import org.json.JSONArray
import org.apache.http.impl.client.DefaultHttpClient
import org.apache.http.util.EntityUtils
import org.apache.http.client.methods.HttpGet
import android.content.Context
import android.support.v4.app.LoaderManager.LoaderCallbacks
import java.util.List
import android.support.v4.content.Loader
import android.app.AlertDialog
import java.util.Collections
import android.widget.ArrayAdapter
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import android.widget.ListView
import android.os.Handler
import android.content.Intent
import android.net.Uri

class MainActivity extends FragmentActivity
	implements LoaderCallbacks<List<RankingItem>> {
	
	override protected onCreate(Bundle arg0) {
		super.onCreate(arg0)
		requestWindowFeature(Window.FEATURE_INDETERMINATE_PROGRESS)
		setContentView(R.layout.activity_main)
		h = new Handler()
		listView = findViewById(android.R.id.list) as ListView
		listView.onItemClickListener = [p, v, pos, id |
			val item = listView.getItemAtPosition(pos) as RankingItem
			startActivity(new Intent(Intent.ACTION_VIEW,
				Uri.parse("https://twitter.com/" + item.name)
			))
		]
		supportLoaderManager.initLoader(0, null, this)
	}
	
	var ListView listView
	var Handler h
	
	override onCreateLoader(int arg0, Bundle arg1) {
		setProgressBarIndeterminateVisibility(true)
		new RankingLoader(this)
			=> [forceLoad()]
	}
	
	override onLoadFinished(Loader<List<RankingItem>> arg0, List<RankingItem> arg1) {
		h.post([|
			setProgressBarIndeterminateVisibility(false)
			
			if (arg1 == null) {
				new AnonymousDialogFragment([f, b |
					new AlertDialog.Builder(this)
						.setMessage("Azure óéÇøÇƒÇÒÇ∂Ç·ÇÀÅ[ÇÃÅH")
						.setPositiveButton(android.R.string.ok, [d, w |])
						.create()
				], null).show(supportFragmentManager, "error")
			} else {
				Collections.sort(arg1, [x, y |
					-x.level.compareTo(y.level)
				])
			}
			
			listView.adapter = new RankingAdapter(this, arg1)
		])
	}
	
	override onLoaderReset(Loader<List<RankingItem>> arg0) { }
}

@Data
class RankingItem {
	String name
	Integer level
}

class RankingLoader extends AsyncTaskLoader<List<RankingItem>> {
	
	new(Context context) {
		super(context)
	}
	
	override loadInBackground() {
		try {
			val client = new DefaultHttpClient()
			val res = client.execute(
				new HttpGet(
					"https://alpacabokujodata.azure-mobile.net/api/alpacaapi"
				)
			)
			val j = new JSONArray(EntityUtils.toString(
				res.entity
			))
			(0..j.length - 1).map[
				val item = j.getJSONObject(it)
				new RankingItem(
					item.getString("name"),
					item.getInt("value")
				)
			].toList()
		} catch (Exception e) {
			e.printStackTrace()
			null
		}
	}
	
}

class RankingAdapter extends ArrayAdapter<RankingItem> {
	new(Context context, List<RankingItem> items) {
		super(context,
			android.R.layout.simple_list_item_2,
			android.R.id.text1,
			items
		)
	}
	
	override getView(int position, View convertView, ViewGroup parent) {
		val view = super.getView(position, convertView, parent)
		val item = getItem(position)
		(view.findViewById(android.R.id.text1) as TextView).setText("@" + item.name)
		(view.findViewById(android.R.id.text2) as TextView).setText("ÉåÉxÉã " + item.level)
		view
	}
	
}
