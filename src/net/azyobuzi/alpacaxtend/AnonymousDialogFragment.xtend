package net.azyobuzi.alpacaxtend

import android.support.v4.app.DialogFragment
import java.io.Serializable
import android.os.Bundle
import android.app.Dialog
import android.content.DialogInterface

class AnonymousDialogFragment extends DialogFragment {
	new() {
		super()
	}


	new(AnonymousDialogFragmentOnCreateDialog onCreateDialogHandler, AnonymousDialogFragmentOnCancel onCancelHandler) {
		super()
		arguments = new Bundle() => [
			putSerializable("onCreateDialog", onCreateDialogHandler)
			putSerializable("onCancel", onCancelHandler)
		]
	}


	override onCreateDialog(Bundle savedInstanceState) {
		(arguments.getSerializable("onCreateDialog") as AnonymousDialogFragmentOnCreateDialog)
			.onCreateDialog(this, savedInstanceState)
	}


	override onCancel(DialogInterface dialog) {
		(arguments.getSerializable("onCancel") as AnonymousDialogFragmentOnCancel)
			?.onCancel(this, dialog)
	}


}


interface AnonymousDialogFragmentOnCreateDialog extends Serializable {
	def Dialog onCreateDialog(AnonymousDialogFragment fragment, Bundle savedInstanceState)
}


interface AnonymousDialogFragmentOnCancel extends Serializable {
	def void onCancel(AnonymousDialogFragment fragment, DialogInterface dialog)
}