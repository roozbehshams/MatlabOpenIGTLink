MatlabOpenIGTLink
=================
This project provides modular and easy to use implementaion for OpenIGTLink  protocol using MATLAB. Current verstion can send STRING, TRANSFORM and NDArray(1D Float Array) messages and can receive STRING and TRANSFORM messages.

It is based on MATLAB bridge implemented by Andras Lasso.

-----------------------------------------

We will be adding more message types and will work to make it more user friendly. As Standard MATLAB license does not allow multitastking
OR multi-threading we can not run receiver and sender at the same time. But, we have tried to make it kind of callback based implementation for
the receiver which may be helpful in managing the message workflow. 

Please leave your feedback or email us ur suggestions to make it more userfriendly. ALso please report us any failures.
