/*
 * Copyright 2014 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.samples.apps.iosched.ui.widget;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.support.v7.appcompat.R;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewAnimationUtils;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.animation.AnimationUtils;
import android.view.animation.Interpolator;
import android.widget.Checkable;
import android.widget.FrameLayout;

/**
 * A Floating Action Button is a {@link android.widget.Checkable} view distinguished by a circled
 * icon floating above the UI, with special motion behaviors.
 */
public class FloatingActionButton extends FrameLayout implements Checkable {

	/**
	 * An array of states.
	 */
	private static final int[] CHECKED_STATE_SET = {
			android.R.attr.state_checked
	};

	private static String TAG = "FloatingActionButton";

	/**
	 * A boolean that tells if the FAB is checked or not.
	 */
	protected boolean mChecked;

	/**
	 * A boolean that tells if the FAB is checked or not.
	 */
	protected boolean mCheckable;

	protected boolean mVisible;

	/*/
	 * The {@link View} that is revealed.
	 */
	protected View mRevealView;

	/**
	 * A {@link android.view.GestureDetector} to detect touch actions.
	 */
	private GestureDetector mGestureDetector;

	/**
	 * A listener to communicate that the FAB has changed its state.
	 */
	private OnCheckedChangeListener mOnCheckedChangeListener;

	private final Interpolator mInterpolator;

	public FloatingActionButton(Context context) {
		this(context, null, 0, 0);
	}

	public FloatingActionButton(Context context, AttributeSet attrs) {
		this(context, attrs, 0, 0);
	}

	public FloatingActionButton(Context context, AttributeSet attrs, int defStyleAttr) {
		this(context, attrs, defStyleAttr, 0);
	}

	@TargetApi(Build.VERSION_CODES.LOLLIPOP)
	public FloatingActionButton(Context context, AttributeSet attrs, int defStyleAttr,
			int defStyleRes) {
		super(context, attrs, defStyleAttr);

		// When a view is clickable it will change its state to "pressed" on every click.
		setClickable(true);
		setCheckable(true);

		mVisible = getVisibility() == View.VISIBLE;

		//		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
		//			mInterpolator = AnimationUtils.loadInterpolator(getContext(), android.R.interpolator.fast_out_slow_in);
		//		else
		mInterpolator = AnimationUtils.loadInterpolator(getContext(), android.R.interpolator.accelerate_decelerate);

		// Create a {@link GestureDetector} to detect single taps.
		mGestureDetector = new GestureDetector(context,
				new GestureDetector.SimpleOnGestureListener() {
					@Override
					public boolean onSingleTapConfirmed(MotionEvent e) {
						toggle();
						return true;
					}
				}
				);

		// A new {@link View} is created
		mRevealView = new View(context);
		addView(mRevealView, ViewGroup.LayoutParams.MATCH_PARENT,
				ViewGroup.LayoutParams.MATCH_PARENT);
	}

	/**
	 * Sets the checkable/uncheckable state of the FAB.
	 * 
	 * @param checkable
	 */
	public void setCheckable(boolean checkable) {
		mCheckable = checkable;
	}

	/**
	 * Sets the checked/unchecked state of the FAB.
	 * 
	 * @param checked
	 */
	@Override
	public void setChecked(boolean checked) {
		// If trying to set the current state, ignore.
		if (!mCheckable || checked == mChecked) {
			return;
		}
		mChecked = checked;

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
			// Create and start the {@link ValueAnimator} that shows the new state.
			Animator anim = createAnimator();
			anim.setDuration(getResources().getInteger(android.R.integer.config_shortAnimTime));
			anim.start();

			// Set the new background color of the {@link View} to be revealed.
			mRevealView.setBackgroundColor(
					mChecked ? getResources().getColor(R.color.fab_checked)
							: getResources().getColor(R.color.fab_normal)
					);

			// Show the {@link View} to be revealed. Note that the animation has started already.
			mRevealView.setVisibility(View.VISIBLE);
		} else
			refreshDrawableState();

		if (mOnCheckedChangeListener != null) {
			mOnCheckedChangeListener.onCheckedChanged(this, checked);
		}
	}

	public void setOnCheckedChangeListener(OnCheckedChangeListener listener) {
		mOnCheckedChangeListener = listener;
		setClickable(listener != null);
	}

	/**
	 * Interface definition for a callback to be invoked when the checked state
	 * of a compound button changes.
	 */
	public static interface OnCheckedChangeListener {

		/**
		 * Called when the checked state of a FAB has changed.
		 *
		 * @param fabView
		 *            The FAB view whose state has changed.
		 * @param isChecked
		 *            The new checked state of buttonView.
		 */
		void onCheckedChanged(FloatingActionButton fabView, boolean isChecked);
	}

	@TargetApi(Build.VERSION_CODES.LOLLIPOP)
	protected Animator createAnimator() {
		// Calculate the longest distance from the hot spot to the edge of the circle.
		Animator anim = ViewAnimationUtils.createCircularReveal(
				mRevealView, getWidth() / 2, getHeight() / 2, 0, getWidth() / 2);
		anim.addListener(new AnimatorListenerAdapter() {
			@Override
			public void onAnimationEnd(Animator animation) {
				// Now we can refresh the drawable state
				refreshDrawableState();

				mRevealView.setVisibility(View.GONE);
			}
		});
		return anim;
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		if (mGestureDetector.onTouchEvent(event)) {
			return true;
		}
		return super.onTouchEvent(event);
	}

	@Override
	public boolean isChecked() {
		return mChecked;
	}

	public void show() {
		show(true);
	}

	public void hide() {
		hide(true);
	}

	public void show(boolean animate) {
		showHide(true, animate, false);
	}

	public void hide(boolean animate) {
		showHide(false, animate, false);
	}

	private void showHide(final boolean visible, final boolean animate, boolean force) {
		if (mVisible != visible || force) {
			mVisible = visible;
			int height = getHeight();
			if (height == 0 && !force) {
				ViewTreeObserver vto = getViewTreeObserver();
				if (vto.isAlive()) {
					vto.addOnPreDrawListener(new ViewTreeObserver.OnPreDrawListener() {
						@Override
						public boolean onPreDraw() {
							ViewTreeObserver currentVto = getViewTreeObserver();
							if (currentVto.isAlive()) {
								currentVto.removeOnPreDrawListener(this);
							}
							showHide(visible, animate, true);
							return true;
						}
					});
					return;
				}
			}
			int translationY = visible ? 0 : height + getMarginBottom();
			if (animate) {
				animate().setInterpolator(mInterpolator)
						.setDuration(getResources().getInteger(android.R.integer.config_shortAnimTime))
						.translationY(translationY);
			} else {
				setTranslationY(translationY);
			}
		}
	}

	private int getMarginBottom() {
		int marginBottom = 0;
		final ViewGroup.LayoutParams layoutParams = getLayoutParams();
		if (layoutParams instanceof ViewGroup.MarginLayoutParams) {
			marginBottom = ((ViewGroup.MarginLayoutParams) layoutParams).bottomMargin;
		}
		return marginBottom;
	}

	@Override
	public void toggle() {
		setChecked(!mChecked);
	}

	@Override
	protected void onSizeChanged(final int w, final int h, int oldw, int oldh) {
		super.onSizeChanged(w, h, oldw, oldh);

		//		ViewOutlineProvider viewOutlineProvider = new ViewOutlineProvider() {
		//			@Override
		//			public void getOutline(View view, Outline outline) {
		//				// Or read size directly from the view's width/height
		//				outline.setOval(0, 0, view.getWidth(), view.getHeight());
		//			}
		//		};
		//		setOutlineProvider(viewOutlineProvider);
		//		setClipToOutline(true);
	}

	@Override
	protected int[] onCreateDrawableState(int extraSpace) {
		final int[] drawableState = super.onCreateDrawableState(extraSpace + 1);
		if (isChecked()) {
			mergeDrawableStates(drawableState, CHECKED_STATE_SET);
		}
		return drawableState;
	}
}
