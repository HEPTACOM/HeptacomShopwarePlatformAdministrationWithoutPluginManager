<?php declare(strict_types=1);

namespace Heptacom\Shopware\Administration\WithoutPluginManager\Api\Controller;

use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

class Deny
{
    public function deny(): Response
    {
        return JsonResponse::create([
            'success' => false,
            'message' => 'It is not allowed to control plugins via API',
        ], Response::HTTP_FORBIDDEN);
    }
}
