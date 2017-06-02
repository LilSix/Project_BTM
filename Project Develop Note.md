# Project Develop Note

### 使用 `@try` 來執行例外處理

```
@try {
    // Code that can potentially throw an exception.
} @catch (NSException *exception) {
    // Handle an exception thrown in the @try block.
} @finally {
    // Code that gets executed whether or not an exception is thrown.
}
```
