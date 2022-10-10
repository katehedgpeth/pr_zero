export function throwIfUnexpectedKey<T>(
  key: string,
  expectedKeys: Array<keyof T>,
  interfaceName: string
): keyof T {
  if (expectedKeys.includes(key as keyof T) === false) {
    throw new Error(`Unexpected key for ${interfaceName}: ${key}`);
  }
  return key as keyof T;
}

type ParsedKV<T> = [keyof T, T[keyof T]];

export type Parser<RawKey, RawVal, T> = (
  key: RawKey,
  val: RawVal
) => ParsedKV<T>;

export type Parsers<T, Parsed> = {
  [P in keyof Parsed]: Parser<P, Parsed[P], T>;
};

const isParsedKey = <Raw, T, Parsed>(
  key: keyof Parsed | keyof Raw,
  parsers: Parsers<T, Parsed>
): key is keyof Parsed => Object.hasOwn(parsers, key);

type EmptyObject = Omit<Record<"never", never>, "never">;

export function parseKeyVal<T, Parsed extends EmptyObject, Raw extends Parsed>({
  maybeKey,
  val,
  expectedKeys,
  parsers,
  rawName,
}: {
  expectedKeys: Array<keyof Raw>;
  maybeKey: string;
  rawName: string;
  val: Raw[expectedKeys[0]];
  parsers: Parsers<T, Parsed>;
}): [keyof T, T[keyof T]] {
  const key = throwIfUnexpectedKey<Raw>(maybeKey, expectedKeys, rawName);
  if (isParsedKey<Raw, T, Parsed>(key, parsers)) {
    return parsers[key](key, val) as ParsedKV<T>;
  }
  return [key, val] as unknown as ParsedKV<T>;
}
