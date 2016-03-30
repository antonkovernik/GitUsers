//
//  Animator.swift
//  GitHubUsers
//
//  Created by Anton Kovernyk on 3/29/16.
//  Copyright © 2016 none. All rights reserved.
//

import UIKit


class Animator: NSObject, UIViewControllerAnimatedTransitioning {
  let duration    = 0.3
  var presenting  = true
  var originFrame = CGRect.zero
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return duration
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    
    let containerView = transitionContext.containerView()!
    let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
    
    let avatarView = presenting ? toView : transitionContext.viewForKey(UITransitionContextFromViewKey)!
    
    let initialFrame = presenting ? originFrame : avatarView.frame
    let finalFrame = presenting ? avatarView.frame : originFrame
    
    let xScaleFactor = presenting ?
      initialFrame.width / finalFrame.width :
      finalFrame.width / initialFrame.width
    
    let yScaleFactor = presenting ?
      initialFrame.height / finalFrame.height :
      finalFrame.height / initialFrame.height
    
    let scaleTransform = CGAffineTransformMakeScale(xScaleFactor, yScaleFactor)
    
    if presenting {
      avatarView.transform = scaleTransform
      avatarView.center = CGPoint(
        x: CGRectGetMidX(initialFrame),
        y: CGRectGetMidY(initialFrame))
      avatarView.clipsToBounds = true
    }
    
    containerView.addSubview(toView)
    containerView.bringSubviewToFront(avatarView)
    
    let herbController = transitionContext.viewControllerForKey(
      presenting ? UITransitionContextToViewControllerKey : UITransitionContextFromViewControllerKey
      ) as! AvatarPreviewViewController
    
    if presenting {
      herbController.view.alpha = 0.0
    }
    
    UIView.animateWithDuration(duration, delay:0.0,
                               options: [],
                               animations: {
                                avatarView.transform = self.presenting ? CGAffineTransformIdentity : scaleTransform
                                avatarView.center = CGPoint(x: CGRectGetMidX(finalFrame), y: CGRectGetMidY(finalFrame))
                                herbController.view.alpha = self.presenting ? 1.0 : 0.0
                                
      }, completion:{_ in
        transitionContext.completeTransition(true)
    })
  }
}
