/**
 * Adds child DOM elements or other valid children to a parent DOM element.
 * @param parent The parent DOM element.
 * @param children A variadic list of children to add.
 * @returns The parent DOM element for chaining.
 */
@module("vanjs-core") @scope("default")
external add: (Dom.element, 'a) => Dom.element = "add"

/**
 * Represents a state object with a mutable `val` field.
 */
type state<'a> = {mutable val: 'a}

/**
 * Creates a new state object.
 * @param initialValue The initial value of the state.
 * @returns A state object with a mutable `val` field.
 */
@module("vanjs-core") @scope("default")
external state: 'a => state<'a> = "state"

/**
 * Creates a derived state object based on a derivation function.
 * @param f A function that derives a value based on other states.
 * @returns A derived state object that updates automatically.
 */
@module("vanjs-core") @scope("default")
external derive: (unit => 'a) => state<'a> = "derive"

module Tags = {
  /**
   * Represents the namespace of an element.
   */
  type namespace =
    | Html
    | Svg
    | MathMl
    | Custom(string)

  type child
  external childFrom: @unwrap [#Str(string) | #Number(float)] => child = "%identity"
  // external childFromElement: Dom.element => child = "%identity"
  // external childFromString: string => child = "%identity"
  // external childFromFloat: float => child = "%identity"
  // external childFromState: state<'a> => child = "%identity"
  // external childFromFunction: (unit => 'a) => child = "%identity"


  /**
   * Retrieves the `tags` proxy object for the default HTML namespace.
   * @returns A proxy object for creating HTML elements.
   */
  @module("vanjs-core")  @scope("default")
  external tags: @unwrap [#Str(string) | #Unit(unit)] => 'a = "tags"

  // Helper function to unwrap the polymorphic variant
  let unwrapChild = (child: child): 'a => {
    switch Js.Json.classify(Obj.magic(child)) {
    | JSONObject(dict) =>
      switch Js.Dict.get(dict, "NAME") {
      | Some(_) =>
        switch Js.Dict.get(dict, "VAL") {
        | Some(val) => Obj.magic(val)
        | None => Obj.magic(child)
        }
      | None => Obj.magic(child)
      }
    | _ => Obj.magic(child)
    }
  }


  /**
   * Resolves the namespace to its string representation.
   * @param namespace The namespace type (e.g., `Html`, `Svg`).
   * @returns An optional string representing the namespace URI.
   */
  let resolveNamespace: namespace => option<string> = namespace => {
    switch namespace {
    | Html => None
    | Svg => Some("http://www.w3.org/2000/svg")
    | MathMl => Some("http://www.w3.org/1998/Math/MathML")
    | Custom(ns) => Some(ns)
    }
  }

  /**
   * Creates a DOM element with optional properties and children.
   * @param namespace The namespace of the element (e.g., `Html`, `Svg`).
   * @param tagName The name of the tag (e.g., `"div"`, `"span"`).
   * @param properties An object containing attributes for the element.
   * @param children An array of children to append to the element.
   * @returns The created DOM element.
   */
  let createTag: (
    ~namespace: namespace=?,
    ~tagName: string,
    ~properties: {..}=?,
    ~children: array<child>=?,
  ) => Dom.element = (
    ~namespace as ns=Html,
    ~tagName,
    ~properties as props=Object.make(),
    ~children=[],
  ) => {
    let proxy = switch resolveNamespace(ns) {
    | Some(n) => tags(#Str(n))
    | None => tags(#Unit())
    }
    Console.log2("Hola", children)
    let processedChildren = children->Array.map(unwrapChild)

    %raw(`(proxy, tagName, props, children) => proxy[tagName](props, ...children)`)(
      proxy,
      tagName,
      props,
      // children,
      processedChildren
    )
  }
}
