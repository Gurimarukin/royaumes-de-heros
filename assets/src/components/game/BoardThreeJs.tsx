import styled from '@emotion/styled'
import React, { Profiler, createRef, useCallback, useContext, useMemo, useRef } from 'react'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'

import { CardDatasContext } from '../../contexts/CardDatasContext'
import { CardData } from '../../models/game/CardData'
import { Game } from '../../models/game/Game'
import { params } from '../../params'
import { Dict, List, Maybe, inspect, pipe } from '../../utils/fp'

interface Props {
  // readonly game: Game
}

export const BoardThreeJs = (props: Props): JSX.Element => {
  const cardDatas = useContext(CardDatasContext)

  const canvasRef = useRef<HTMLCanvasElement | null>(null)

  // const onMount = useCallback(
  //   (elt: HTMLCanvasElement | null): void => {
  //     console.log('onMount')

  //     if (elt !== null && canvasRef.current === null) mountElt(elt, cardDatas, props)

  //     canvasRef.current = elt
  //   },
  //   [cardDatas, props],
  // )
  const onMount = useMemo(() => {
    console.log('update onMount')
    return getOnMount(cardDatas, props)
  }, [])

  return (
    <Container>
      <Canvas ref={onMount} />
    </Container>
  )
}

function logMount(elt: HTMLElement | null) {
  console.log('logMount =', elt)
}

function onClick(e: React.MouseEvent) {
  console.log('e =', e)
  e.stopPropagation()
  e.preventDefault()
}

function getOnMount(
  cardDatas: Dict<CardData>,
  props: Props,
): (elt: HTMLCanvasElement | null) => void {
  return elt => {
    console.log('onMount')
    if (elt !== null) mountElt(elt, cardDatas, props)
  }
}

function mountElt(canvas: HTMLCanvasElement, cardDatas: Dict<CardData>, {}: Props): void {
  console.log('mountElt')
  const width = canvas.offsetWidth
  const height = canvas.offsetHeight

  const fov = 75
  const aspect = width / height
  const near = 1
  const far = 10000

  const scene = new THREE.Scene()
  const camera = new THREE.PerspectiveCamera(fov, aspect, near, far)
  const renderer = new THREE.WebGLRenderer({ canvas })
  // renderer.setSize(width, height, false)

  // const hand = game.player[1].hand.map(([, { key }]) =>
  //   pipe(
  //     Dict.lookup(key, cardDatas),
  //     Maybe.fold(
  //       () => {
  //         throw new Error(`Unknown card: ${key}`)
  //       },
  //       c => card(),
  //     ),
  //   ),
  // )

  const mesh = card()

  const axes = new THREE.AxesHelper(50)
  if (Array.isArray(axes.material)) {
    axes.material.forEach(m => {
      m.depthTest = false
    })
  } else {
    axes.material.depthTest = false
  }
  axes.renderOrder = 1

  const controls = new OrbitControls(camera, canvas)

  // scene
  scene.add(axes)
  scene.add(mesh)

  // camera
  camera.position.z = params.card.height

  // controls.update() must be called after any manual changes to the camera's transform
  controls.update()

  requestAnimationFrame(render)

  function render(/* time: number */) {
    if (resizeRendererToDisplaySize(renderer)) {
      // const canvas = renderer.domElement;
      camera.aspect = canvas.offsetWidth / canvas.offsetHeight
      camera.updateProjectionMatrix()
    }

    // const seconds = time * 0.001
    // mesh.rotation.x = seconds
    // mesh.rotation.y = seconds

    // mesh.rotation.x += 0.02
    // mesh.rotation.y += 0.02

    // required if controls.enableDamping or controls.autoRotate are set to true
    controls.update()

    renderer.render(scene, camera)
    requestAnimationFrame(render)
  }
}

function card(): THREE.Object3D {
  // const geometry = new THREE.PlaneGeometry(params.card.width, params.card.height)

  /**
   *   a────b
   *  ╱      ╲
   * h        c
   * │        │
   * │        │
   * │        │
   * g        d
   *  ╲      ╱
   *   f────e
   */

  const halfWidth = params.card.width / 2
  const halfHeight = params.card.height / 2

  const aX = -halfWidth + params.card.borderRadius
  const aY = -halfHeight
  const bX = -aX
  const bY = aY
  const cX = halfWidth
  const cY = -halfHeight + params.card.borderRadius
  const dX = cX
  const dY = -cY
  const eX = bX
  const eY = -bY
  const fX = aX
  const fY = -aY
  const gX = -dX
  const gY = dY
  const hX = -cX
  const hY = cY
  const shape = new THREE.Shape()
  shape.moveTo(bX, bY)
  shape.quadraticCurveTo(halfWidth, -halfHeight, cX, cY)
  shape.lineTo(dX, dY)
  shape.quadraticCurveTo(halfWidth, halfHeight, eX, eY)
  shape.lineTo(fX, fY)
  shape.quadraticCurveTo(-halfWidth, halfHeight, gX, gY)
  shape.lineTo(hX, hY)
  shape.quadraticCurveTo(-halfWidth, -halfHeight, aX, aY)

  const geometry = new THREE.ShapeBufferGeometry(shape)

  const loader = new THREE.TextureLoader()
  const front = new THREE.MeshBasicMaterial({
    map: loader.load('/images/cards/arkus.jpg'),
    side: THREE.FrontSide,
  })
  const back = new THREE.MeshBasicMaterial({
    map: loader.load(CardData.hidden),
    side: THREE.BackSide,
  })
  const materials = [front, back]

  return createMultiMaterialObject(geometry, materials)
}

function resizeRendererToDisplaySize(renderer: THREE.WebGLRenderer): boolean {
  const canvas = renderer.domElement

  const pixelRatio = window.devicePixelRatio
  const width = Math.floor(canvas.offsetWidth * pixelRatio)
  const height = Math.floor(canvas.offsetHeight * pixelRatio)

  const needResize = canvas.width !== width || canvas.height !== height
  if (needResize) renderer.setSize(width, height, false)

  return needResize
}

function createMultiMaterialObject(
  geometry: THREE.BufferGeometry,
  materials: THREE.Material[],
): THREE.Group {
  const group = new THREE.Group()

  materials.forEach(material => {
    const mesh = new THREE.Mesh(geometry, material)
    fixTexture(mesh)
    group.add(mesh)
  })

  return group
}

function fixTexture(mesh: THREE.Mesh<THREE.BufferGeometry>): void {
  const box = new THREE.Box3().setFromObject(mesh)
  const size = new THREE.Vector3()

  box.getSize(size)

  const vec3 = new THREE.Vector3() // temp vector
  const attPos = mesh.geometry.attributes.position
  const attUv = mesh.geometry.attributes.uv

  List.range(0, attPos.count - 1).forEach(i => {
    vec3.fromBufferAttribute(attPos, i)
    attUv.setXY(i, (vec3.x - box.min.x) / size.x, (vec3.y - box.min.y) / size.y)
  })
}

const Container = styled.div({
  flexGrow: 1,
  height: '100vh',
  overflow: 'hidden',
  backgroundImage: "url('/images/bg.jpg')",
  backgroundSize: '100% 100%',
})

const Canvas = styled.canvas({
  width: '100%',
  height: '100%',
})
