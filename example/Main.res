@val @scope("document") @return(nullable)
external getElementById: string => option<Dom.element> = "getElementById"

let root = switch getElementById("root") {
| Some(el) => el
| None => Exn.raiseError("Root element not found")
}

@get external getEventTarget: Dom.event => Dom.eventTarget = "target"
@get external getInputValue: Dom.eventTarget => string = "value"

let deriveState: unit => Dom.element = () => {
  let vanText = Van.state("VanJs")
  let length = Van.derive(() => vanText.val->String.length)

  Van.Dom.createElement("div")
  ->Van.Dom.appendChildren([
    Text("The length of the text is: "),
    Dom(Van.Dom.createElement("input")
    ->Van.Dom.attr({
      "type": "text",
      "value": vanText.val,
      "oninput": (event: Dom.event) => vanText.val = event->getEventTarget->getInputValue,
    })
    ->Van.Dom.build),
    State(length)
  ])
  ->Van.Dom.build
}

Van.add(root, [Dom(deriveState())])->ignore
