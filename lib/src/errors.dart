enum Errors {
  pointMissingKeyframe('Missing parent Keyframe for Point.'),
  keyframeMissingAnimation('Missing parent Animation for Keyframe.'),
  pointMissingLabel('Point is missing a label.'),
  stateMissingLabel('Animation is missing a state.'),
  malformedKeyframe('Keyframe must have fields: dur x y w h originx originy.'),
  malformedPoint('Point must have fields: x y.'),
  malformedEmpty('Empty must have fields: duration.');

  final String message;
  const Errors(this.message);
}
