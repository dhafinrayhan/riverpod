import raw from "!!raw-loader!./raw.dart";
import codegen from "!!raw-loader!./async_notifier.dart";

export default {
  raw,
  hooks: raw,
  codegen,
  hooksCodegen: codegen,
};
