Kitchen Navigator v12 Alpha 6 - Horizontal Overflow Fix

Fixes the RenderFlex overflow on narrow Android screens.

Recipes:
- Header is now responsive using LayoutBuilder.
- On narrower screens, Add Recipe becomes a compact + icon button.
- Long header text ellipsizes safely.
- Recipe filters now use Wrap instead of forcing everything into one Row.
- 30 min / My recipes / sort control can flow to another line.

Planner:
- Custom-recipe labels are allowed to ellipsize safely.

Resolves:
- A RenderFlex overflowed by ~90 pixels on the right.

Install:
1. Extract ZIP.
2. Copy lib and test into:
   C:\Projects\KitchenNavigator
3. Merge / Replace.
4. Run:
   C:\src\flutter\bin\flutter.bat test
   C:\src\flutter\bin\flutter.bat run -d R5CY91DJ6EA

Phone test:
- Open Recipes.
- Confirm no yellow/black right-overflow stripe.
- Rotate / resize if possible.
- Test My recipes, 30 min filter and sort.
- Confirm Add Recipe remains accessible.

After successful testing:
   git add lib test
   git commit -m "Fix Alpha 6 recipe header overflow"
   git push
