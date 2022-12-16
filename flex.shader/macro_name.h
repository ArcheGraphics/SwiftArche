//   Copyright (c) 2022 Feng Yang
//
//   I am making my contributions/submissions to this project solely in my
//   personal capacity and am not conveying any rights to any intellectual
//   property of any third parties.

#pragma once

// int have no verb, other will use:
// HAS_ : Resouce
// OMMIT_ : Omit Resouce
// NEED_ : Shader Operation
// IS_ : Shader control flow
// _COUNT: type int constant
typedef enum {
    IS_OVER_LAPPING = 39999,
    HAS_SDF = 39998
} FlexMacro;
