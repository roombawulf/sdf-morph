import { useRef } from "react";
import { extend, useFrame } from "@react-three/fiber";
import { shaderMaterial } from "@react-three/drei";
import { useControls } from "leva";
import * as THREE from 'three';
import vertex from "./vertex.glsl";
import fragment from "./fragment.glsl";


const BlobMaterial = shaderMaterial(
    { u_time: 0.0, u_morph_sphere: 0.5, u_morph_cube: 0.5, u_morph_torus: 0.5 },
    vertex,
    fragment
);
extend( { BlobMaterial } )


function Blob () {

    const shaderMaterial = useRef()

    const { sphereMorph, cubeMorph, torusMorph } = useControls(' Morph! ', {
        sphereMorph: { value: 0.5, step: 0.05, max: 1.0, min: 0.0 },
        cubeMorph: { value: 0.5, step: 0.05, max: 1.0, min: 0.0 },
        torusMorph: { value: 0.5, step: 0.05, max: 1.0, min: 0.0 },
    })

    useFrame((state, delta) => {
        shaderMaterial.current.u_time = state.clock.elapsedTime

        shaderMaterial.current.u_morph_sphere = sphereMorph
        shaderMaterial.current.u_morph_cube = cubeMorph
        shaderMaterial.current.u_morph_torus = torusMorph
    })

    return (
        <mesh>
            <boxGeometry args={[ 3,3,3 ]} />
            <blobMaterial ref={shaderMaterial} key={BlobMaterial.key} transparent side={THREE.BackSide} />
        </mesh>
    )
}
export default Blob


