#Leaves

This fork offers a couple of new transition styles: scrolling (like in the Kindle app) and slide over (like in Safari). Refer to the [original README][1] for how to add to your project. 

![Leaves Preview][2]

To add a leaves view controller, subclass LeavesViewController and override the initialize method with the view that for the transition style you'd like

    - (void)initialize 
    {
        leavesView = [[SlideLeavesView alloc] initWithFrame:CGRectZero];
    }


[1]:https://github.com/brow/leaves/blob/master/README.markdown "Leaves README"
[2]:https://github.com/diegobelfiore/leaves/blob/master/Resources/preview.png "Leaves Preview"